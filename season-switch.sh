#!/bin/bash
# Monthly Wallpaper Auto-Switcher for Seasons Theme
# Sets the appropriate wallpaper based on the current month

set -e

THEME_DIR="$HOME/.config/omarchy/themes/seasons/backgrounds"
CURRENT_MONTH=$(date +%-m)

# Map month number to wallpaper file
case $CURRENT_MONTH in
  1)  WALLPAPER="01-january-winter.jpg" ;;
  2)  WALLPAPER="02-february-winter.jpg" ;;
  3)  WALLPAPER="03-march-spring.jpg" ;;
  4)  WALLPAPER="04-april-spring.jpg" ;;
  5)  WALLPAPER="05-may-spring.jpg" ;;
  6)  WALLPAPER="06-june-summer.jpg" ;;
  7)  WALLPAPER="07-july-summer.jpg" ;;
  8)  WALLPAPER="08-august-summer.jpg" ;;
  9)  WALLPAPER="09-september-autumn.jpg" ;;
  10) WALLPAPER="10-october-autumn.jpg" ;;
  11) WALLPAPER="11-november-autumn.jpg" ;;
  12) WALLPAPER="12-december-winter.jpg" ;;
  *)  echo "Error: Invalid month"; exit 1 ;;
esac

WALLPAPER_PATH="$THEME_DIR/$WALLPAPER"

if [ ! -f "$WALLPAPER_PATH" ]; then
  echo "Error: Wallpaper not found: $WALLPAPER_PATH"
  exit 1
fi

echo "Setting wallpaper for $(date +'%B): $WALLPAPER"
omarchy-theme-bg-set "$WALLPAPER_PATH"
echo "Done."
