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

    testImplementation("org.jetbrains.kotlin:kotlin-test:1.8.+")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit:1.8.+")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:+")
    testImplementation("org.robolectric:robolectric:4.+")
    androidTestImplementation("com.android.support.test:runner:+")
}

kotlin {
    jvmToolchain {
        languageVersion.set(JavaLanguageVersion.of("11"))
    }
}

android {
    namespace = group as String
    sourceSets.getByName("main") {
        kotlin.setSrcDirs(listOf("Sources/${group}"))
    }
    sourceSets.getByName("test") {
        kotlin.setSrcDirs(listOf("Tests/${group}Tests"))
    }
    // not yet working
    //sourceSets.getByName("androidTest") {
    //    kotlin.setSrcDirs(listOf("Tests/${group}Tests"))
    //}
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
