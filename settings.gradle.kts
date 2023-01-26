pluginManagement {
    repositories {
        gradlePluginPortal()
        mavenCentral()
        google()
    }
}

sourceControl {
    gitRepository(java.net.URI.create("https://github.com/jectivex/CrossFoundation.git")) {
        producesModule("CrossFoundation:CrossFoundation")
    }
}
