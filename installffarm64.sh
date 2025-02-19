#!/bin/bash

# Define Firefox download URL (ARM64 version)
FIREFOX_URL="https://download.mozilla.org/?product=firefox-nightly-latest-l10n-ssl&os=linux64-aarch64&lang=nb-NO"
INSTALL_DIR="/userdata/system/firefox"
FIREFOX_BIN="$INSTALL_DIR/firefox"
PORTS_DIR="/userdata/roms/ports"

# Create directories if they don't exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$PORTS_DIR"
mkdir -p "/usr/bin"

# Download and extract Firefox
echo "Downloading Firefox for ARM64..."
curl -L "$FIREFOX_URL" -o "/userdata/system/firefox.tar.bz2"

echo "Extracting Firefox..."
tar -xjf "/userdata/system/firefox.tar.bz2" -C "$INSTALL_DIR" --strip-components=1
rm "/userdata/system/firefox.tar.bz2"

# Create a symlink in /usr/bin for easier access
ln -sf "$FIREFOX_BIN" /usr/bin/firefox

# Create a launch script for Batocera's Ports section
echo "Creating Firefox launch script..."
cat <<EOF > "$PORTS_DIR/firefox.sh"
#!/bin/bash
$FIREFOX_BIN
EOF

chmod +x "$PORTS_DIR/firefox.sh"

# Add Firefox to the Ports menu
echo "Updating Ports menu..."
GAMELIST="$PORTS_DIR/gamelist.xml"
FIREFOX_ICON="/userdata/roms/ports/images/firefox.png"

# Ensure gamelist.xml exists
if [ ! -f "$GAMELIST" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?><gameList></gameList>' > "$GAMELIST"
fi

# Download an icon for Firefox
mkdir -p "/userdata/roms/ports/images"
curl -Ls -o "$FIREFOX_ICON" "https://upload.wikimedia.org/wikipedia/commons/a/a0/Firefox_logo%2C_2019.png"

# Add Firefox entry to gamelist.xml
xmlstarlet ed -s "/gameList" -t elem -n "game" -v "" \
  -s "/gameList/game[last()]" -t elem -n "path" -v "./firefox.sh" \
  -s "/gameList/game[last()]" -t elem -n "name" -v "Firefox Browser" \
  -s "/gameList/game[last()]" -t elem -n "image" -v "./images/firefox.png" \
  "$GAMELIST" > "$GAMELIST.tmp" && mv "$GAMELIST.tmp" "$GAMELIST"

# Reload Batocera game list
curl http://127.0.0.1:1234/reloadgames

echo "Firefox installation complete! You can now launch it from the Ports menu in Batocera."
