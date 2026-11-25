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

    val androidExt = project.extensions.findByName("android")
    if (androidExt is com.android.build.api.dsl.CommonExtension<*, *, *, *, *, *>) {
        androidExt.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
