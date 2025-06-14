// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")    // ← Firebase & Google Sign-In
    id("dev.flutter.flutter-gradle-plugin") // ← Flutter Gradle plugin
}

android {
    namespace = "Unicornianos.SI.passmgr_mobile"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "Unicornianos.SI.passmgr_mobile"
        minSdk         = flutter.minSdkVersion
        targetSdk      = flutter.targetSdkVersion
        versionCode    = flutter.versionCode
        versionName    = flutter.versionName
    }

    buildTypes {
        debug {
            // Si quieres puedes personalizar el debug aquí
        }
        release {
            // Usamos la debug key para que flutter run --release siga funcionando
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
}

flutter {
    source = "../.."
}
