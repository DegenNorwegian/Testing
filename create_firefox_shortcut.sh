#!/bin/bash

# Variables
APPNAME="Firefox"
INSTALL_DIR="/userdata/system/firefox"  # Existing Firefox installation path
DESKTOP_FILE="/usr/share/applications/${APPNAME,,}.desktop"
PERSISTENT_DESKTOP="/userdata/system/configs/${APPNAME,,}/${APPNAME,,}.desktop"
ICON_URL="https://upload.wikimedia.org/wikipedia/commons/a/a0/Firefox_logo%2C_2019.png"
ICON_PATH="/userdata/system/add-ons/${APPNAME,,}/extra/icon.png"
EXEC_PATH="${INSTALL_DIR}/firefox"

# Check if the Firefox executable exists
if [ ! -f "$EXEC_PATH" ]; then
    echo "Firefox executable not found at ${EXEC_PATH}. Please ensure Firefox is installed correctly."
    exit 1
fi

# Create necessary directories
mkdir -p "$(dirname "$PERSISTENT_DESKTOP")"
mkdir -p "$(dirname "$ICON_PATH")"

# Download icon
echo "Downloading icon..."
curl -L -o "$ICON_PATH" "$ICON_URL"

# Create persistent desktop entry
echo "Creating persistent desktop entry for ${APPNAME}..."
cat <<EOF > "$PERSISTENT_DESKTOP"
[Desktop Entry]
Version=1.0
Type=Application
Name=${APPNAME}
Exec=${EXEC_PATH}
Icon=${ICON_PATH}
Terminal=false
Categories=Network;WebBrow
