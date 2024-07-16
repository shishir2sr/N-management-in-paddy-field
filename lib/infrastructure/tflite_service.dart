import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rice_fertile_ai/core/shared/logging_service.dart';
import 'package:rice_fertile_ai/domain/tensor4d.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract class InterpreterManager {
  Future<Interpreter> createInterpreter({required String assetPath});
  void closeInterpreter({required Interpreter interpreter});
}

abstract class ModelRunner {
  Future<Tensor4D?> runPreProcessorModel({
    required Interpreter interpreter,
    required Tensor4D input,
    required Tensor4D output,
  });

  Future<dynamic> runClassificatinModel({
    required Interpreter interpreter,
    required Uint8List input,
  });
}

// New TFLite service class implementing both interfaces
class TFLiteService implements InterpreterManager, ModelRunner {
  @override
  Future<Interpreter> createInterpreter({required String assetPath}) async {
    final interpreter = await Interpreter.fromAsset(assetPath);

    logger.i('Interpreter created');
    return interpreter;
  }

  @override
  void closeInterpreter({required Interpreter interpreter}) {
    interpreter.close();
    logger.i('Interpreter closed');
  }

  @override
  Future runClassificatinModel(
      {required Interpreter interpreter, required Uint8List input}) {
    // TODO: implement runClassificatinModel
    throw UnimplementedError();
  }

  @override
  Future<Tensor4D?> runPreProcessorModel({
    required Interpreter interpreter,
    required Tensor4D input,
    required Tensor4D output,
  }) async {
    var inputTensor = input;
    var outputTensor = output;

    interpreter.run(inputTensor, outputTensor);
    return outputTensor;
  }
}

final modelRunnerProvider = Provider<ModelRunner>((ref) => TFLiteService());
final interpreterManagerProvider =
    Provider<InterpreterManager>((ref) => TFLiteService());

// create a future family autodispose provider to create interpreter for each model
final interpreterProvider =
    FutureProvider.autoDispose.family<Interpreter, String>(
  (ref, assetPath) async {
    ref.onDispose(() {
      logger.i('Disposing interpreter');
    });

    final interpreterManager = ref.watch(interpreterManagerProvider);
    return interpreterManager.createInterpreter(assetPath: assetPath);
  },
);
