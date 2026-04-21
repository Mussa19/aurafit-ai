<<<<<<< HEAD
plugins {
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false
}

android {
    namespace = "com.example.aurafit_ai"

    // Explicitly set SDK version to avoid old build tools issues
    compileSdk = 34
    targetSdk = 34 

=======
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "kz.konina.aurafit_ai"
    compileSdk = flutter.compileSdkVersion
>>>>>>> master
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        applicationId = "com.example.aurafit_ai"

        // Minimum SDK for Firebase and modern libraries
        minSdk = flutter.minSdkVersion
        targetSdk = 34

=======
        applicationId = "kz.konina.aurafit_ai"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
>>>>>>> master
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

<<<<<<< HEAD
    buildTypes {
        release {
            // Using debug signing for testing (not for production)
            signingConfig = signingConfigs.getByName("debug")
=======
    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String
            keyPassword = keyProperties["keyPassword"] as String
            storeFile = file(layout.projectDirectory.file(keyProperties["storeFile"] as String))
            storePassword = keyProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
>>>>>>> master
        }
    }
}

flutter {
    source = "../.."
<<<<<<< HEAD
}
=======
}
>>>>>>> master
