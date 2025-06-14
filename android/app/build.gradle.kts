// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")           // ← Añadido para Firebase/Google Sign-In
    id("dev.flutter.flutter-gradle-plugin")       // ← El plugin de Flutter al final
}

android {
    namespace = "Unicornianos.SI.passmgr_mobile"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "Unicornianos.SI.passmgr_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
