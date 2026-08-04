#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	libdbusmenu-glib

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package

# If the application needs to be manually built that has to be done down here
echo "Getting VS Code..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	x86_64)  farch=x64;;
	aarch64) farch=arm64;;
esac

DOWNLOAD_URL=$(curl -sI -o /dev/null -w '%{redirect_url}' \
	"https://code.visualstudio.com/sha/download?build=stable&os=linux-$farch")

wget --retry-connrefused --tries=30 "$DOWNLOAD_URL" -O /tmp/vscode.tar.gz

mkdir -p ./AppDir/bin ./AppDir/share/applications
tar -xvf /tmp/vscode.tar.gz
mv -v ./VSCode-linux-*/* ./AppDir/bin

# Extract version
VERSION=$(awk -F'"' '/"version":/ {print $4}' ./AppDir/bin/resources/app/package.json)
echo "$VERSION" > ~/version
echo "VS Code version: $VERSION"

wget --retry-connrefused --tries=30 https://raw.githubusercontent.com/microsoft/vscode/refs/heads/main/resources/linux/code-url-handler.desktop -O ./AppDir/share/applications/code-url-handler.desktop
wget --retry-connrefused --tries=30 https://raw.githubusercontent.com/microsoft/vscode/refs/heads/main/resources/linux/code.desktop -O ./AppDir/code.desktop

sed -i \
	-e 's/@@NAME_SHORT@@/Code/g'              \
	-e 's/@@NAME@@/code/g'                    \
	-e 's#@@EXEC@@#code#g'                    \
	-e 's/@@ICON@@/visual-studio-code/g'      \
	-e 's/@@URLPROTOCOL@@/vscode/g'           \
	-e 's/@@NAME_LONG@@/Visual Studio Code/g' \
	./AppDir/code.desktop ./AppDir/share/applications/code-url-handler.desktop

# not needed
rm -rf ./AppDir/bin/resources/app/node_modules/@github/copilot-linuxmusl-x64
