import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing configuration.
//
// Credentials are NEVER committed. They are read, in order of precedence, from:
//   1. android/key.properties  (git-ignored, see android/key.properties.example)
//   2. environment variables   (CI):
//        BOKER_KEYSTORE_PATH, BOKER_KEYSTORE_PASSWORD,
//        BOKER_KEY_ALIAS, BOKER_KEY_PASSWORD
//
// When no credentials are available the release build is left unsigned
// (`flutter build appbundle` still produces an unsigned AAB that can be signed
// later with Play App Signing / jarsigner). Debug keys are never used for
// release builds.
// ---------------------------------------------------------------------------
val keystoreProperties = Properties().apply {
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

fun signingValue(propertyKey: String, envKey: String): String? =
    (keystoreProperties.getProperty(propertyKey) ?: System.getenv(envKey))
        ?.takeIf { it.isNotBlank() }

val releaseStoreFilePath = signingValue("storeFile", "BOKER_KEYSTORE_PATH")
val releaseStorePassword = signingValue("storePassword", "BOKER_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingValue("keyAlias", "BOKER_KEY_ALIAS")
val releaseKeyPassword = signingValue("keyPassword", "BOKER_KEY_PASSWORD")

val hasReleaseSigning = releaseStoreFilePath != null &&
    releaseStorePassword != null &&
    releaseKeyAlias != null &&
    releaseKeyPassword != null &&
    rootProject.file(releaseStoreFilePath).exists()

android {
    namespace = "com.boker.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications, which uses java.time APIs.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.boker.app"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = rootProject.file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Release builds are signed with the release keystore when one is
            // configured. They are never signed with the debug keys.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "BOKER: no release signing configuration found " +
                        "(android/key.properties or BOKER_KEYSTORE_* env vars). " +
                        "The release build will be left unsigned."
                )
                null
            }
        }
    }
}

// Firebase Cloud Messaging is optional: the google-services plugin is only
// applied when android/app/google-services.json has been provided. Without it
// the project still builds and runs, push notifications simply stay disabled
// (see lib/core/services/notifications/push_notifications_service.dart).
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.lifecycle(
        "BOKER: android/app/google-services.json not found - " +
            "Firebase Cloud Messaging will be disabled at runtime."
    )
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// ---------------------------------------------------------------------------
// Dependency pinning.
//
// flutter_local_notifications / flutter_secure_storage pull in
// androidx.core 1.19.0, whose AAR metadata hard-requires compileSdk 37 and
// Android Gradle plugin 9.1.0+. Flutter 3.47 stable still builds against
// compileSdk 36 with AGP 8.11.x, so androidx.core is held at the last release
// that targets SDK 36. Remove these lines once Flutter stable moves to AGP 9.
// ---------------------------------------------------------------------------
configurations.configureEach {
    resolutionStrategy {
        force(
            "androidx.core:core:1.17.0",
            "androidx.core:core-ktx:1.17.0",
        )
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
