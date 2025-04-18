import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:LCC/core/shared/logging_service.dart';
import 'package:LCC/domain/typedefs.dart';
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

  int runClassificatinModel({
    required Interpreter interpreter,
    required Tensor4D input,
    required List<List<double>> output,
  });
}

// New TFLite service class implementing both interfaces
class TFLiteService implements InterpreterManager, ModelRunner {
  @override
  Future<Interpreter> createInterpreter({required String assetPath}) async {
    try {
      final interpreter = await Interpreter.fromAsset(assetPath);
      logger.i('Interpreter created from: $assetPath');
      return interpreter;
    } catch (e) {
      logger.e('Error creating interpreter: $e');
      throw Exception('Error creating interpreter');
    }
  }

  @override
  void closeInterpreter({required Interpreter interpreter}) {
    interpreter.close();
  }

  @override
  int runClassificatinModel({
    required Interpreter interpreter,
    required Tensor4D input,
    required Tensor2D output,
  }) {
    final modelInput = input;
    final modelOutput = output;

    interpreter.run(modelInput, modelOutput);
    logger.i('Model output: $modelOutput');

    return _getLabelFromOutput(modelOutput);
  }

  int _getLabelFromOutput(Tensor2D modelOutput) {
    final classificationLabels = [2, 3, 4, 5];
    List<double> flattenedOutput = modelOutput.flatten();

    int maxIndex = flattenedOutput.indexWhere((element) =>
        element ==
        flattenedOutput.reduce((curr, next) => curr > next ? curr : next));

    return classificationLabels[maxIndex];
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
    final interpreterManager = ref.watch(interpreterManagerProvider);
    final interpreter =
        await interpreterManager.createInterpreter(assetPath: assetPath);
    ref.onDispose(() {
      interpreterManager.closeInterpreter(interpreter: interpreter);
    });

    return interpreter;
  },
);
