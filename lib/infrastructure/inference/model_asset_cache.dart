import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'package:LCC/core/shared/logging_service.dart';

/// Extracts the `.tflite` assets to real files so the inference isolate can
/// open them with `Interpreter.fromFile`, which memory-maps the model instead
/// of `calloc`-ing it (`Interpreter.fromAsset` goes through
/// `Model.fromBuffer`, whose buffer is never freed).
///
/// This deliberately runs on the **root** isolate. Both plausible ways to read
/// an asset from a spawned isolate fail:
///   * `rootBundle.load` reaches for `ServicesBinding.instance`, which does not
///     exist there → `Binding has not yet been initialized`.
///   * Sending `flutter/assets` over `BackgroundIsolateBinaryMessenger`
///     (after `ensureInitialized`) gets a null reply from the engine, which
///     then blows up inside the messenger's own response handler with
///     `type 'Null' is not a subtype of type 'List<dynamic>'`.
///
/// The cost is a transient ~24 MB `ByteData` on the UI isolate, one model at a
/// time, and only when the cache is cold — the sidecar stamp means a warm start
/// does no asset reading at all.
class ModelAssetCache {
  const ModelAssetCache();

  /// Bump when the `.tflite` assets change, so an app update re-extracts them
  /// instead of leaving the previous install's copies in place.
  static const int version = 1;

  /// Resolves [assetKeys] to on-disk paths, extracting any that are missing or
  /// stale. Returns paths in the same order as the input.
  Future<List<String>> ensureExtracted(List<String> assetKeys) async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);

    final paths = <String>[];
    for (final assetKey in assetKeys) {
      paths.add(await _ensureOne(assetKey, directory));
    }
    return paths;
  }

  Future<String> _ensureOne(String assetKey, Directory directory) async {
    final fileName = assetKey.split('/').last;
    final target = File('${directory.path}/$fileName');
    final stamp = File('${target.path}.v');

    if (await target.exists() && await target.length() > 0) {
      final cached = await stamp.exists()
          ? int.tryParse((await stamp.readAsString()).trim())
          : null;
      if (cached == version) return target.path;
    }

    logger.i('Extracting $assetKey');

    final asset = await rootBundle.load(assetKey);

    // Written to a temporary name and renamed, so a process kill mid-write
    // cannot leave a truncated model that would later fail to load — or, worse,
    // load and then crash natively.
    final temp = File('${target.path}.tmp');
    await temp.writeAsBytes(
      asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes),
      flush: true,
    );
    await temp.rename(target.path);

    // Written last, so an interrupted extraction leaves the cache invalid
    // rather than pointing at a partial file.
    await stamp.writeAsString('$version', flush: true);

    logger.i('Extracted $fileName (${asset.lengthInBytes} bytes)');
    return target.path;
  }
}
