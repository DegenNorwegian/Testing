#!/bin/bash

# Define Dolphin download URL (ARM64 Flatpak version)
DOLPHIN_URL="https://dl.dolphin-emu.org/releases/2412/dolphin-2412-aarch64.flatpak"
INSTALL_DIR="/userdata/system/dolphin"
DOLPHIN_BIN="$INSTALL_DIR/dolphin-emu"
PORTS_DIR="/userdata/roms/ports"

# Create necessary directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$PORTS_DIR"
mkdir -p "/usr/bin"

# Download Dolphin Flatpak
echo "Downloading Dolphin Emulator for ARM64..."
curl -L "$DOLPHIN_URL" -o "/userdata/system/dolphin.flatpak"

# Attempt to extract the Flatpak (treat as archive)
echo "Extracting Dolphin Flatpak..."
# Flatpak files are usually OCI images or archives, attempt extraction
if command -v bsdtar &> /dev/null; then
    bsdtar -xf "/userdata/system/dolphin.flatpak" -C "$INSTALL_DIR"
else
    echo "bsdtar not found! Please install bsdtar to extract the Flatpak."
    exit 1
fi
rm "/userdata/system/dolphin.flatpak"

# Check if the Dolphin binary exists
if [ ! -f "$DOLPHIN_BIN" ]; then
    echo "Error: Dolphin binary not found after extraction."
    exit 1
fi

# Make the Dolphin binary executable
chmod +x "$DOLPHIN_BIN"

# Create a symlink in /usr/bin for easier access
ln -sf "$DOLPHIN_BIN" /usr/bin/dolphin-emu

# Create a launch script for Batocera's Ports section
echo "Creating Dolphin launch script..."
cat <<EOF > "$PORTS_DIR/dolphin.sh"
#!/bin/bash
$DOLPHIN_BIN
EOF

chmod +x "$PORTS_DIR/dolphin.sh"

# Add Dolphin to the Ports menu
echo "Updating Ports menu..."
GAMELIST="$PORTS_DIR/gamelist.xml"
DOLPHIN_ICON="/userdata/roms/ports/images/dolphin.png"

# Ensure gamelist.xml exists
if [ ! -f "$GAMELIST" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$GAMELIST"
fi

# Download an icon for Dolphin
mkdir -p "/userdata/roms/ports/images"
curl -Ls -o "$DOLPHIN_ICON" "https://upload.wikimedia.org/wikipedia/commons/3/37/Dolphin_emulator_logo.png"

# Add Dolphin entry to gamelist.xml
xmlstarlet ed -s "/gameList" -t elem -n "game" -v "" \
  -s "/gameList/game[last()]" -t elem -n "path" -v "./dolphin.sh" \
  -s "/gameList/game[last()]" -t elem -n "name" -v "Dolphin Emulator" \
  -s "/gameList/game[last()]" -t elem -n "image" -v "./images/dolphin.png" \
  "$GAMELIST" > "$GAMELIST.tmp" && mv "$GAMELIST.tmp" "$GAMELIST"

# Reload Batocera game list
curl http://127.0.0.1:1234/reloadgames

echo "Dolphin Emulator installation complete! You can now launch it from the Ports menu in Batocera."
