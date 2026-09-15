#!/usr/bin/env bash
# Automatiza una publicación nueva de DECIDE:
# sube el número de build, compila el APK y la web, publica la web en
# Firebase Hosting, y crea un release en GitHub con el APK adjunto.
#
# Uso: scripts/release.sh ["notas de la version (opcional)"]

set -euo pipefail
cd "$(dirname "$0")/.."

FLUTTER="/c/Users/gar_e/Desktop/flutter/bin/flutter"
GH="/c/Program Files/GitHub CLI/gh.exe"
NOTES="${1:-Nueva version de DECIDE.}"

CURRENT=$(grep -m1 '^version:' pubspec.yaml | sed 's/version: //')
VERSION_NAME="${CURRENT%%+*}"
BUILD_NUM="${CURRENT##*+}"
NEW_BUILD_NUM=$((BUILD_NUM + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_BUILD_NUM}"
TAG="v${NEW_VERSION}"

echo "==> Version actual: $CURRENT -> Nueva: $NEW_VERSION"
sed -i "s/^version: .*/version: ${NEW_VERSION}/" pubspec.yaml

echo "==> Compilando APK..."
"$FLUTTER" build apk --release

echo "==> Compilando web..."
"$FLUTTER" build web --release

echo "==> Publicando web en Firebase Hosting..."
firebase deploy --only hosting --project decide-app-rusito

echo "==> Guardando el cambio de version en git..."
git add pubspec.yaml
git commit -m "Version ${NEW_VERSION}"
git tag "$TAG"
git push origin HEAD
git push origin "$TAG"

echo "==> Creando el release en GitHub con el APK adjunto..."
"$GH" release create "$TAG" \
  build/app/outputs/flutter-apk/app-release.apk \
  --title "DECIDE ${NEW_VERSION}" \
  --notes "$NOTES"

echo "==> Listo. Release: $TAG"
