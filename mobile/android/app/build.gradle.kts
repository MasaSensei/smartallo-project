plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.masasensei.smartallo"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.masasensei.smartallo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdkVersion(24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
            
            // Perbaikan untuk Kotlin DSL:
            isMinifyEnabled = true   // Pake 'is' dan '='
            isShrinkResources = true // Pake 'is' dan '='
            
            // Cara panggil proguardFiles di Kotlin DSL:
            setProguardFiles(listOf(
                getDefaultProguardFile("proguard-android-optimize.txt"), 
                "proguard-rules.pro"
            ))
        }
    }
}

flutter {
    source = "../.."
}
