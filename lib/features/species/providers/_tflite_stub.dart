// Web stub for tflite_flutter — keeps dart2js/Wasm compilation happy.
// TFLite inference is always guarded by kIsWeb checks at runtime.
// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:typed_data';

class Interpreter {
  static Future<Interpreter> fromAsset(
    String assetPath, {
    InterpreterOptions? options,
  }) async {
    throw UnsupportedError('TFLite not available on web');
  }

  void run(Object input, Object output) {
    throw UnsupportedError('TFLite not available on web');
  }

  TensorStub getOutputTensor(int index) {
    throw UnsupportedError('TFLite not available on web');
  }

  void close() {}
}

class TensorStub {
  List<int> get shape => [];
}

class InterpreterOptions {}

extension ListShape on List {
  List reshape(List<int> shape) {
    throw UnsupportedError('TFLite not available on web');
  }
}

extension Float32ListShape on Float32List {
  List reshape(List<int> shape) {
    throw UnsupportedError('TFLite not available on web');
  }
}
