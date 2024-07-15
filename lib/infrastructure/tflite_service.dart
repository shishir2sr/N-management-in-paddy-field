import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/tensor4d.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class InterpreterManager {
  Future<IsolateInterpreter> createInterpreter({required String assetPath});
  void closeInterpreter({required IsolateInterpreter interpreter});
}

abstract class ModelRunner {
  Tensor4D? runPreProcessorModel({
    required IsolateInterpreter interpreter,
    required Tensor4D input,
    required Tensor4D output,
  });

  Future<dynamic> runClassificatinModel({
    required IsolateInterpreter interpreter,
    required Uint8List input,
  });
}

// New TFLite service class implementing both interfaces
class TFLiteService implements InterpreterManager, ModelRunner {
  @override
  Future<IsolateInterpreter> createInterpreter(
      {required String assetPath}) async {
    final interpreter = await Interpreter.fromAsset(assetPath);
    final isolateInterpreter =
        await IsolateInterpreter.create(address: interpreter.address);
    logger.i('Interpreter created');
    return isolateInterpreter;
  }

  @override
  void closeInterpreter({required IsolateInterpreter interpreter}) {
    interpreter.close();
    logger.i('Interpreter closed');
  }

  @override
  Future runClassificatinModel(
      {required IsolateInterpreter interpreter, required Uint8List input}) {
    // TODO: implement runClassificatinModel
    throw UnimplementedError();
  }

  @override
  Tensor4D? runPreProcessorModel(
      {required IsolateInterpreter interpreter,
      required Tensor4D input,
      required Tensor4D output}) {
    interpreter.run(input, output);
    return output;
  }
}

final modelRunnerProvider = Provider<ModelRunner>((ref) => TFLiteService());
final interpreterManagerProvider =
    Provider<InterpreterManager>((ref) => TFLiteService());

// create a future family autodispose provider to create interpreter for each model
final interpreterProvider = FutureProvider.family<IsolateInterpreter, String>(
  (ref, assetPath) async {
    ref.onDispose(() {
      logger.i('Disposing interpreter');
    });
    final interpreterManager = ref.watch(interpreterManagerProvider);
    return interpreterManager.createInterpreter(assetPath: assetPath);
  },
);
