buildDir = file(".build") // same as SPM

plugins {
    id("com.android.library") version "7.+"
}

repositories {
    mavenCentral()
    google()
}

dependencies {
    testImplementation("junit:junit:4.+")
    testImplementation("org.robolectric:robolectric:4.+")
}

android {
    namespace = "CrossSQL"

    // gradle defaults to sources being in `src/main/java/PACKAGE/`, but SPM expects `Sources/PACKAGE/`
    sourceSets.getByName("main") {
        kotlin.setSrcDirs(listOf("Sources/${namespace}"))
    }

    // gradle defaults to sources being in `src/test/java/PACKAGE/`, but SPM expects `Tests/PACKAGETests/`
    sourceSets.getByName("test") {
        kotlin.setSrcDirs(listOf("Tests/${namespace}Tests"))
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
