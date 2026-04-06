plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aurafit_ai"
    // Прямо указываем версию 34, чтобы убить ошибку 25.0.2
    compileSdk = 34
    buildToolsVersion = "34.0.0" 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.aurafit_ai"
        // Минимальная версия для работы Firebase и современных библиотек
        minSdk = flutter.minSdkVersion 
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Для теста используем debug-ключи, чтобы билд прошел без настройки сертификатов
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
