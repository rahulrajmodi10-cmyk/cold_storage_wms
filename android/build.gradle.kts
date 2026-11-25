allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))
subprojects {
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(project.name))
}

// Align Java and Kotlin JVM targets across plugin subprojects to avoid the
// "Inconsistent JVM Target Compatibility" error (e.g. tflite_flutter sets
// Java 11 in compileOptions while KGP defaults to the host JDK).
subprojects {
    project.evaluationDependsOn(":app")

    val androidExt = project.extensions.findByName("android") as com.android.build.api.dsl.AndroidExtension
    androidExt.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
    androidExt.compileOptions.targetCompatibility = JavaVersion.VERSION_17

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}