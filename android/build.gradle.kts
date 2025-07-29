plugins {
    id("com.android.application") version "8.7.3" apply false // <-- X.X.X yerine 8.7.3 yazın
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false // <-- Bu da doğru versiyon olmalı (genellikle 1.8.0 veya 1.9.0 gibi)
    id("com.google.gms.google-services") version "4.4.1" apply false // Bu satır doğru
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
