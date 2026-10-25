plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    // Core library desugaring for flutter_local_notifications (Java 8+ APIs)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

android {
    namespace = "com.example.cold_storage_wms"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    // Handle TensorFlow Lite transitive dependency namespace conflicts (org.tensorflow.lite)
    // Force a single version of tensorflow-lite to avoid duplicate namespace errors
    configurations.all {
        resolutionStrategy {
            // Force consistent versions across all tensorflow-lite artifacts to avoid namespace conflicts
            // and missing class errors during R8 minification
            force("org.tensorflow:tensorflow-lite:2.14.0")
            force("org.tensorflow:tensorflow-lite-gpu:2.14.0")
            force("org.tensorflow:tensorflow-lite-support:0.4.4")
            force("org.tensorflow:tensorflow-lite-api:2.14.0")
        }
    }

    // Exclude duplicate AndroidManifest.xml from tensorflow-lite modules to resolve namespace conflict
    packaging {
        resources {
            excludes.add("META-INF/org/tensorflow/lite/**")
        }
        jniLibs {
            // Allow duplicate .so files from tensorflow-lite and tensorflow-lite-gpu
            pickFirsts.add("**/libtensorflowlite_jni.so")
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.cold_storage_wms"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // tflite_flutter requires minSdkVersion 26
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://flutter.dev/to/review-gradle-config.)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}