#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

PROJECT="Better Keyboard.xcodeproj"
SCHEME="Better Keyboard"
APP_NAME="Better Keyboard"
NOTARY_PROFILE="${NOTARY_PROFILE:-better-keyboard}"
BUILD_DIR="build/release"

usage() {
    echo "Usage: $0 [--skip-publish]" >&2
    exit 1
}

publish=true
case "${1:-}" in
    "") ;;
    --skip-publish) publish=false ;;
    *) usage ;;
esac

version=$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release -showBuildSettings 2>/dev/null \
    | awk -F' = ' '$1 ~ /^ *MARKETING_VERSION$/ { print $2; exit }')
[[ -n "$version" ]] || { echo "Could not read MARKETING_VERSION" >&2; exit 1; }
tag="v$version"

if $publish; then
    [[ -z "$(git status --porcelain)" ]] || { echo "Working tree is not clean" >&2; exit 1; }
    if git rev-parse -q --verify "refs/tags/$tag" >/dev/null || git ls-remote --exit-code --tags origin "$tag" >/dev/null; then
        echo "Tag $tag already exists. Bump MARKETING_VERSION first." >&2
        exit 1
    fi
    command -v gh >/dev/null || { echo "gh CLI not found (brew install gh)" >&2; exit 1; }
fi

archive="$BUILD_DIR/$APP_NAME.xcarchive"
export_dir="$BUILD_DIR/export"
app="$export_dir/$APP_NAME.app"
zip="$BUILD_DIR/Better-Keyboard-$version.zip"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Archiving $version"
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Release \
    -destination "generic/platform=macOS" -archivePath "$archive" -allowProvisioningUpdates -quiet archive

echo "==> Exporting with Developer ID"
xcodebuild -exportArchive -archivePath "$archive" -exportPath "$export_dir" \
    -exportOptionsPlist scripts/ExportOptions.plist -allowProvisioningUpdates -quiet

codesign --verify --deep --strict "$app"

echo "==> Notarizing"
ditto -c -k --keepParent "$app" "$BUILD_DIR/notarize.zip"
xcrun notarytool submit "$BUILD_DIR/notarize.zip" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$app"
spctl --assess --type execute --verbose "$app"

ditto -c -k --keepParent "$app" "$zip"
shasum -a 256 "$zip"

if ! $publish; then
    echo "==> Built $zip (not published)"
    exit 0
fi

echo "==> Publishing $tag"
git tag "$tag"
git push origin "$tag"
gh release create "$tag" "$zip" --title "$APP_NAME $version" --generate-notes
