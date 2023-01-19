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
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

plugins {
    id("org.jetbrains.kotlin.android") version "1.7.+"
    id("com.android.library") version "7.+"
}

dependencies {
    implementation("androidx.core:core-ktx:1.7.+")
    implementation("androidx.appcompat:appcompat:1.6.+")

    testImplementation("junit:junit:4.+")
    testImplementation("org.jetbrains.kotlin:kotlin-test-junit5")
    testImplementation("org.robolectric:robolectric:4.+")

    androidTestImplementation("androidx.test.ext:junit:1.+")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.+")
}

tasks.withType<Test> {
    this.testLogging {
        this.showStandardStreams = true
    }
}
