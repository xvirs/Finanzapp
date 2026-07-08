#!/bin/sh

# Xcode Cloud post-clone script para apps Flutter.
#
# Apple Cloud hace `xcodebuild archive` directo después de clonar el
# repo, pero proyectos Flutter requieren `flutter pub get` + `pod
# install` ANTES — si los Pods no existen, el archive falla.
#
# Apple ejecuta automáticamente este script después de clone si está
# en `ios/ci_scripts/ci_post_clone.sh` con permisos de ejecución.
#
# Docs: https://developer.apple.com/documentation/xcode/writing-custom-build-scripts

set -e  # Abortar al primer error

echo "=== ci_post_clone.sh — preparando build Flutter ==="

# 1. Instalar Flutter SDK fresco. Apple Cloud no lo trae preinstalado.
#    PINEADO a 3.35.7 — la misma versión que usa el CI de GitHub Actions
#    y con la que se desarrolló el proyecto. NO usar `stable`: clona la
#    última (hoy 3.44.x), que fuerza la integración de Swift Package
#    Manager (migra google_sign_in a SPM) y el build revienta con
#    "a resolved file is required ... swiftpm/Package.resolved". Con
#    3.35.7 no pasa. Si se sube la versión, sincronizar con
#    FLUTTER_VERSION en .github/workflows/*.yml.
echo "--- Instalando Flutter SDK (3.35.7) ---"
git clone --depth 1 --branch 3.35.7 https://github.com/flutter/flutter.git "$HOME/flutter"
export PATH="$PATH:$HOME/flutter/bin"

# 2. Verificar Flutter funcional.
flutter --version
flutter doctor -v || true  # `|| true` porque doctor puede emitir warnings que no son bloqueantes

# 3. Instalar FlutterFire CLI. Lo necesita un build phase script de
#    Crashlytics que sube los dSYMs (`flutterfire
#    upload-crashlytics-symbols`). Sin esto, el archive falla con
#    "flutterfire: command not found".
echo "--- Instalando FlutterFire CLI ---"
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire --version

# 4. Bajar dependencias Dart.
echo "--- flutter pub get ---"
cd "$CI_WORKSPACE"
flutter pub get

# 4. Pre-cache iOS artifacts (libflutter.framework, etc).
echo "--- flutter precache ---"
flutter precache --ios

# 5. Build iOS sin firma. `flutter build ios` corre `flutter pub get`
#    + `pod install` + `xcodebuild` internamente, dejando los Pods +
#    Generated.xcconfig listos para que el archive de Xcode Cloud (que
#    corre después de este script) los encuentre OK.
#
#    NOTA: NO hace falta un `pod install` adicional al final — el de
#    flutter build ya lo dejó hecho. Un cd a "$CI_WORKSPACE/ios" acá
#    fallaba porque $CI_WORKSPACE se vacía después de los comandos
#    intermedios (no es estable entre subshells del runner).
echo "--- flutter build ios --release --no-codesign ---"
flutter build ios --release --no-codesign

echo "=== ci_post_clone.sh terminado OK ==="
