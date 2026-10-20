plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.untungku.untungku_pro"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Stable package ID used for Play and future updates.
        applicationId = "id.untungku.untungku_pro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = 36
        manifestPlaceholders["admobAppId"] = System.getenv("ADMOB_ANDROID_APP_ID") ?: "ca-app-pub-3940256099942544~3347511713"
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("production") {
            val signingFile = file(System.getenv("ANDROID_KEYSTORE_PATH") ?: "release.jks")
            if (signingFile.exists()) {
                storeFile = signingFile
                storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("ANDROID_KEY_PASSWORD")
            }
        }
    }
    buildTypes {
        release {
            // Releases require the owner upload key; never fall back to debug signing.
            signingConfig = signingConfigs.getByName("production")
        }
    }
}

flutter {
    source = "../.."
}
