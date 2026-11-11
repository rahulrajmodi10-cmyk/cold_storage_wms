pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0" apply false
    id("com.android.application") version "9.0.0" apply false
    id("org.jetbrains.kotlin.android") version "1.7.22" apply false

    // Pin Kotlin to 1.7.22 to avoid JavaVersion.parse("25.0.3") issue
    // Kotlin 2.x can't parse Java version string from Android Studio JBR
}

include(":app")
