#!/bin/bash
# Seasons Theme Installer for Omarchy Quattro
# Installs the theme and particle overlay plugin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="$SCRIPT_DIR/theme"
PLUGIN_SRC="$SCRIPT_DIR/plugin"
THEME_DEST="$HOME/.config/omarchy/themes/seasons"
PLUGIN_DEST="$HOME/.config/omarchy/plugins/local.seasons"

echo "Installing Seasons theme for Omarchy Quattro..."
echo ""

# Install theme
echo "Installing theme to $THEME_DEST..."
mkdir -p "$THEME_DEST/backgrounds"
cp "$THEME_SRC/colors.toml" "$THEME_DEST/"
cp "$THEME_SRC/icons.theme" "$THEME_DEST/"
cp "$THEME_SRC/preview.png" "$THEME_DEST/"
cp "$THEME_SRC/backgrounds/"*.jpg "$THEME_DEST/backgrounds/"
echo "  Theme files copied."

# Install plugin
echo "Installing particle plugin to $PLUGIN_DEST..."
mkdir -p "$PLUGIN_DEST"
cp "$PLUGIN_SRC/manifest.json" "$PLUGIN_DEST/"
cp "$PLUGIN_SRC/Seasons.qml" "$PLUGIN_DEST/"
cp "$PLUGIN_SRC/season-switch.sh" "$PLUGIN_DEST/"
chmod +x "$PLUGIN_DEST/season-switch.sh"
echo "  Plugin files copied."

# Enable plugin in shell.json
SHELL_JSON="$HOME/.config/omarchy/shell.json"
if [ -f "$SHELL_JSON" ]; then
  # Check if local.seasons is already in plugins array
  if ! grep -q '"local.seasons"' "$SHELL_JSON"; then
    echo "Enabling plugin in shell.json..."
    # Add to plugins array using python
    python3 -c "
import json
with open('$SHELL_JSON', 'r') as f:
    config = json.load(f)
plugins = config.get('plugins', [])
if not any(p.get('id') == 'local.seasons' for p in plugins):
    plugins.append({'id': 'local.seasons'})
    config['plugins'] = plugins
    with open('$SHELL_JSON', 'w') as f:
        json.dump(config, f, indent=2)
    print('  Plugin enabled.')
else:
    print('  Plugin already enabled.')
"
  else
    echo "  Plugin already enabled in shell.json."
  fi
else
  echo "  Warning: shell.json not found. Plugin installed but not enabled."
  echo "  Run: omarchy-shell shell rescanPlugins"
fi

echo ""
echo "Installation complete!"
echo ""
echo "To apply the theme, run:"
echo "  omarchy theme set seasons"
echo ""
echo "The particle overlay will automatically detect the current month"
echo "and display seasonal animations:"
echo "  Winter (Dec-Feb): Falling snowflakes"
echo "  Spring (Mar-May): Rain showers"
echo "  Summer (Jun-Aug): Floating dandelion seeds"
echo "  Autumn (Sep-Nov): Falling leaves"
echo ""
echo "To change wallpaper manually:"
echo "  omarchy theme bg set ~/.config/omarchy/themes/seasons/backgrounds/01-january-winter.jpg"
echo ""
