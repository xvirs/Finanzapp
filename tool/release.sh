#!/usr/bin/env bash
#
# tool/release.sh — un solo comando para publicar una actualización.
#
# Qué hace:
#   1. Lee la versión actual de pubspec.yaml (formato `version: X.Y.Z+N`).
#   2. Calcula la nueva versión (bump patch/minor/major, o la que le pases).
#   3. SIEMPRE incrementa el build number (+N) → nunca te rechaza la store
#      por "build number repetido", que es el error #1 de los releases.
#   4. Actualiza pubspec.yaml, commitea, crea el tag vX.Y.Z y lo pushea.
#   5. El push del tag dispara solo:
#        - release-android.yml  → AAB firmado → Play Store (track production)
#        - release-ios.yml      → IPA firmado → App Store Connect / TestFlight
#
# Uso:
#   ./tool/release.sh patch     # 1.1.0 -> 1.1.1   (bugfix)
#   ./tool/release.sh minor     # 1.1.0 -> 1.2.0   (features)
#   ./tool/release.sh major     # 1.1.0 -> 2.0.0   (cambios grandes)
#   ./tool/release.sh 1.5.0     # versión exacta
#
# Requisitos: estar en la raíz del repo, working tree limpio.
#
set -euo pipefail

PUBSPEC="pubspec.yaml"

# --- 0. Sanity checks ------------------------------------------------------
if [[ ! -f "$PUBSPEC" ]]; then
  echo "❌ No encuentro $PUBSPEC. Corré esto desde la raíz del repo." >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "❌ Tenés cambios sin commitear. Limpiá el working tree antes de releasear:" >&2
  git status --short >&2
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "Uso: ./tool/release.sh <patch|minor|major|X.Y.Z>" >&2
  exit 1
fi

# --- 1. Leer versión actual ------------------------------------------------
# Línea esperada: `version: 1.1.0+4`
current_line="$(grep -E '^version:' "$PUBSPEC" | head -1)"
current="${current_line#version: }"
current="$(echo "$current" | tr -d '[:space:]')"

name_part="${current%%+*}"   # 1.1.0
build_part="${current##*+}"  # 4

IFS='.' read -r major minor patch <<< "$name_part"

# --- 2. Calcular nueva versión ---------------------------------------------
case "$1" in
  patch) patch=$((patch + 1)) ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  major) major=$((major + 1)); minor=0; patch=0 ;;
  *.*.*) IFS='.' read -r major minor patch <<< "$1" ;;
  *)
    echo "❌ Argumento inválido: '$1'. Usá patch | minor | major | X.Y.Z" >&2
    exit 1
    ;;
esac

new_name="${major}.${minor}.${patch}"
new_build=$((build_part + 1))
new_version="${new_name}+${new_build}"
tag="v${new_name}"

# --- 3. Confirmar ----------------------------------------------------------
branch="$(git rev-parse --abbrev-ref HEAD)"
echo "──────────────────────────────────────────────"
echo "  Versión actual : ${current}"
echo "  Nueva versión  : ${new_version}"
echo "  Tag            : ${tag}"
echo "  Rama           : ${branch}"
echo "──────────────────────────────────────────────"
echo "Esto va a: editar pubspec.yaml, commitear, crear el tag y pushear."
echo "El push del tag DISPARA el deploy a Play Store (producción) y App Store Connect."
read -r -p "¿Continuar? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelado. No se tocó nada."
  exit 0
fi

# Verificar que el tag no exista ya
if git rev-parse "$tag" >/dev/null 2>&1; then
  echo "❌ El tag $tag ya existe. ¿Ya releaseaste esta versión?" >&2
  exit 1
fi

# --- 4. Aplicar -----------------------------------------------------------
# Reemplazo seguro de la línea de versión (compatible con sed de macOS).
sed -i '' -E "s/^version:.*/version: ${new_version}/" "$PUBSPEC"

git add "$PUBSPEC"
git commit -m "chore(release): ${new_name} (build ${new_build})"
git tag "$tag"
git push origin "$branch"
git push origin "$tag"

echo ""
echo "✅ Release ${tag} disparado."
echo "   Seguí el progreso en: https://github.com/xvirs/Finanzapp/actions"
echo ""
echo "   Android → se publica solo en producción cuando termine el workflow."
echo "   iOS     → queda en App Store Connect/TestFlight; entrá a"
echo "             https://appstoreconnect.apple.com y enviá la versión a revisión."
