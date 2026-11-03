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

# Keep Flutter engine and plugin classes (required for release builds with minifyEnabled)
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep sqflite native Android plugin classes (critical for Android database operations)
-keep class com.tekartik.sqflite.** { *; }
-keep class com.tekartik.sqfliteandroid.** { *; }
-keep class io.flutter.plugins.sqflite.** { *; }

# Keep GeneratedPluginRegistrant and all plugin classes
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class de.mintware.barcode_scan.** { *; }
-keep class io.flutter.plugins.camera.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class com.jrai.flutter_keyboard_visibility.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }
-keep class io.flutter.plugins.googlemaps.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
-keep class com.github.dart_lang.jni_flutter.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }
-keep class com.crazecoder.openfile.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class net.nfet.flutter.printing.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.tekartik.sqflite.** { *; }
-keep class dev.fluttercommunity.workmanager.** { *; }

# Keep R classes and resources
-keep class **.R$* { *; }
-keep class com.example.cold_storage_wms.** { *; }

# Prevent warnings from reflection
-dontwarn io.flutter.**
-dontwarn io.flutter.plugins.**
-dontwarn com.example.cold_storage_wms.**