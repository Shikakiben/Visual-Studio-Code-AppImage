#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/microsoft/vscode/refs/heads/main/resources/linux/code.png
export DEPLOY_GTK=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
# Protect the CLI script (bin/bin/code) from being overwritten by an Electron hardlink.
# quick-sharun skips non-executable files, so we make it non-executable temporarily.
chmod -x ./AppDir/bin/bin/code
quick-sharun ./AppDir/bin/*
chmod +x ./AppDir/bin/bin/code

# Route all launches through the CLI script (bin/bin/code).
# This keeps CLI commands working and doesn't affect normal launch.
cat > ./AppDir/bin/cli-router.hook <<'EOF'
exec "$APPDIR/bin/bin/code" "$@"
EOF

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
