# Stub podspec for TensorFlowLiteSwift that avoids cloning the full TensorFlow
# git repo (4GB+). tflite_flutter uses Dart FFI → TensorFlowLiteC (C API).
# The Swift wrapper (TensorFlowLiteSwift) is not used at runtime.
# This stub simply re-exports TensorFlowLiteC which distributes pre-built binaries.

Pod::Spec.new do |s|
  s.name         = 'TensorFlowLiteSwift'
  s.version      = '2.12.0'
  s.summary      = 'TensorFlow Lite for Swift (stub — uses TensorFlowLiteC binary)'
  s.homepage     = 'https://www.tensorflow.org/lite'
  s.license      = { :type => 'Apache 2.0' }
  s.author       = { 'TensorFlow' => 'packages@tensorflow.org' }
  s.source       = { :path => '.' }
  s.ios.deployment_target = '11.0'
  s.static_framework = true

  # Core: the actual TFLite C runtime (pre-built binary, no git clone)
  s.dependency 'TensorFlowLiteC', '2.12.0'

  s.subspec 'Core' do |core|
    core.dependency 'TensorFlowLiteC', '2.12.0'
  end

  s.subspec 'Metal' do |metal|
    metal.dependency 'TensorFlowLiteC/Metal', '2.12.0'
  end

  s.subspec 'CoreML' do |coreml|
    coreml.dependency 'TensorFlowLiteC/CoreML', '2.12.0'
  end
end
