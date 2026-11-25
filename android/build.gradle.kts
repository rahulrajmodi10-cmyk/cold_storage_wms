allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// Align Java and Kotlin JVM targets across plugin subprojects to avoid the
// "Inconsistent JVM Target Compatibility" error (e.g. tflite_flutter sets
// Java 11 in compileOptions while KGP defaults to the host JDK 21).
subprojects {
    project.evaluationDependsOn(":app")
    val androidExt = project.extensions.findByName("android")
    if (androidExt != null) {
        (androidExt as com.android.build.api.dsl.LibraryExtension).compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }
    val kotlinExt = project.extensions.findByName("kotlin")
    if (kotlinExt != null) {
        (kotlinExt as org.jetbrains.kotlin.gradle.dsl.KotlinProjectExtension).compilerOptions.jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
