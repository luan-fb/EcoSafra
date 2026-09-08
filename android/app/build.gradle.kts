plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Lê android/app/google-services.json e injeta a config do Firebase como
    // recursos nativos no build.
    id("com.google.gms.google-services")
}

android {
    namespace = "br.com.ecosafra.ecosafra"
    // O default do Flutter (36) é menor do que o exigido pelo
    // permission_handler_android mais recente (37+). Travamos aqui em vez de
    // usar flutter.compileSdkVersion para não voltar a quebrar numa próxima
    // atualização de dependência.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "br.com.ecosafra.ecosafra"
        // Firebase Auth exige API 23+. Deixamos explícito em vez de usar
        // flutter.minSdkVersion para o build falhar cedo se isso mudar.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            // Keystore de debug do time, versionado em android/keystore/ —
            // não o `~/.android/debug.keystore` padrão, que é único por
            // máquina. Se cada integrante do grupo assinasse com o seu
            // próprio, o Login com Google falharia pra todo mundo menos
            // quem tivesse cadastrado a própria SHA-1 no Firebase: com um
            // keystore compartilhado, todo clone gera o mesmo APK
            // (mesma assinatura), e só uma SHA-1 precisa estar cadastrada.
            //
            // Senha e alias são os defaults do keystore de debug do Android
            // (não é segredo — debug nunca assina o que vai pra Play Store).
            storeFile = file("../keystore/shared_debug.jks")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
