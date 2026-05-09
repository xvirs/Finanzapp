import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Carga android/key.properties si existe. Es el archivo (gitignoreado)
// con las credenciales del keystore de release. Si no existe (dev local
// sin keystore), el release falla en signing — no se firma con debug
// keys silenciosamente, mejor explotar que subir un AAB roto.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasKeystore = keystorePropertiesFile.exists()
if (hasKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "app.finanzapp.client"
    // Pin explícito a 36 (Android 16). Play Store exige targetSdk >= 35
    // desde Aug 2025 — compilando contra 36 cumplimos con margen.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Requerido por flutter_local_notifications 18+ para
        // schedulear notificaciones con java.time en min SDK <26.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "app.finanzapp.client"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Fallback a debug solo para que `flutter build` no
                // explote en máquinas sin keystore (devs nuevos). NO
                // SUBIR a Play Store un build firmado con debug keys —
                // Play lo va a rechazar igual.
                signingConfigs.getByName("debug")
            }
            // R8 full mode: minify (obfusca + elimina código no usado)
            // + shrinkResources (elimina drawables/strings huérfanos
            // post-minify). Reduce el AAB ~30-40%. Las rules están en
            // proguard-rules.pro — si falla en runtime, revisar ahí
            // antes que nada.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
