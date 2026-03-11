#!/bin/bash

# setup_gum.sh
# Downloads and installs gum locally if not found.

set -e

INSTALL_DIR="./bin"
GUM_BINARY="$INSTALL_DIR/gum"

# Check if gum is already installed in system PATH or local bin
if command -v gum >/dev/null 2>&1; then
    echo "gum is already installed in system PATH."
    exit 0
fi

if [ -f "$GUM_BINARY" ]; then
    echo "gum is already present at $GUM_BINARY."
    exit 0
fi

echo "gum not found. Attempting to install locally..."

mkdir -p "$INSTALL_DIR"

# Determine latest version (fallback to specific version if lookup fails)
# Using a known stable version to ensure reliability without complex API parsing dependencies
VERSION="0.13.0" 
PLATFORM="linux_x86_64"
FILENAME="gum_${VERSION}_${PLATFORM}.tar.gz"
URL="https://github.com/charmbracelet/gum/releases/download/v${VERSION}/${FILENAME}"

echo "Downloading gum v${VERSION} from $URL..."
if curl -L -o "gum.tar.gz" "$URL"; then
    echo "Download successful."
else
    echo "Download failed."
    exit 1
fi

echo "Extracting..."
tar -xzf gum.tar.gz

# unexpected tar structure handling: sometimes it's inside a folder
if [ -f "gum_${VERSION}_${PLATFORM}/gum" ]; then
    mv "gum_${VERSION}_${PLATFORM}/gum" "$INSTALL_DIR/"
elif [ -f "gum" ]; then
    mv gum "$INSTALL_DIR/"
else
    # Try to find it
    FOUND_GUM=$(find . -type f -name gum | head -n 1)
    if [ -n "$FOUND_GUM" ]; then
        mv "$FOUND_GUM" "$INSTALL_DIR/"
    else
        echo "Could not find 'gum' binary after extraction."
        rm gum.tar.gz
        exit 1
    fi
fi

chmod +x "$GUM_BINARY"

# Cleanup
rm -rf gum.tar.gz "gum_${VERSION}_${PLATFORM}"

echo "gum installed successfully to $GUM_BINARY"
echo "You can add $INSTALL_DIR to your PATH or run scripts using ./gum_ui.sh"
