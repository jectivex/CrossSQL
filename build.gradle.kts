group = "CrossSQL"

plugins {
    id("org.jetbrains.kotlin.android") version "1.7.+"
    id("com.android.library") version "7.+"
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    implementation("CrossFoundation:CrossFoundation:+")

    testImplementation("junit:junit:4.+")
    testImplementation("org.robolectric:robolectric:4.+")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:+")
    androidTestImplementation("com.android.support.test:runner:+")
}

android {
    namespace = group as String
    sourceSets.getByName("main") {
        kotlin.setSrcDirs(listOf("Sources/${group}"))
    }
    sourceSets.getByName("test") {
        kotlin.setSrcDirs(listOf("Tests/${group}Tests"))
    }
    sourceSets.getByName("androidTest") {
        kotlin.setSrcDirs(listOf("Tests/${group}Tests"))
    }
    compileSdkVersion(33)
    defaultConfig {
        minSdk = 24
        targetSdk = 33
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

tasks.withType<Test> {
    this.testLogging {
        this.showStandardStreams = true
    }
}

buildDir = file(".build") // same as Swift Package Manager
