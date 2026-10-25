# Keep rules for TensorFlow Lite GPU delegate to resolve R8 missing class errors
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }

# Keep TensorFlow Lite support classes
-keep class org.tensorflow.lite.support.** { *; }

# Keep all TensorFlow Lite classes
-keep class org.tensorflow.lite.** { *; }

# Prevent R8 from optimizing away reflection-used classes
-dontwarn org.tensorflow.lite.**