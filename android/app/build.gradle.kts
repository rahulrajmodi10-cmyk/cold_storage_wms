import java.util.Properties

plugins {
    id("com.android.application")
    // Using built-in Kotlin support instead of external Kotlin plugin
    // See: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing credentials. Loaded at script level because the `java` identifier
// inside the `android {}` block resolves to AGP's Java extension, shadowing the
// `java.util` package.
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
}

dependencies {
    // Core library desugaring for flutter_local_notifications (Java 8+ APIs)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

android {
    namespace = "com.example.cold_storage_wms"
    compileSdk = 34
    // build-tools 33.0.0 works better on this Android environment for ProtoLog compatibility
    buildToolsVersion = "33.0.0"
    // Use Flutter default NDK version
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    // Handle TensorFlow Lite transitive dependency namespace conflicts (org.tensorflow.lite)
    // Force a single version of tensorflow-lite to avoid duplicate namespace errors
    // and missing class errors during R8 minification.
    // Using 2.13.0 which has the complete GpuDelegateFactory classes.
    configurations.all {
        resolutionStrategy {
            // Force consistent versions across all tensorflow-lite artifacts to avoid namespace conflicts
            // and missing class errors during R8 minification.
            // Using 2.13.0 which has the complete GpuDelegateFactory classes.
            force("org.tensorflow:tensorflow-lite:2.13.0")
            force("org.tensorflow:tensorflow-lite-gpu:2.13.0")
            force("org.tensorflow:tensorflow-lite-support:0.4.4")
            force("org.tensorflow:tensorflow-lite-api:2.13.0")
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

    signingConfigs {
        getByName("debug") {
            storeFile = file("keystore/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
        create("release") {
            if (keyPropertiesFile.exists()) {
                storeFile = rootProject.file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    // Proguard rules
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.cold_storage_wms"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // tflite_flutter requires minSdkVersion 26
        minSdk = 26
        targetSdk = 34
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://flutter.dev/to/review-gradle-config.)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Enable Multidex for large Flutter apps with many services
        multiDexEnabled = true
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}