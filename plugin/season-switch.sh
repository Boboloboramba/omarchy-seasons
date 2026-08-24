#!/bin/bash
# Seasons Theme Control Script
# Usage:
#   season-switch.sh              Set wallpaper to current month
#   season-switch.sh cycle        Cycle to next season
#   season-switch.sh <season>    Set specific season (winter/spring/summer/autumn)
#   season-switch.sh reset        Reset to automatic month detection

set -e

THEME_DIR="$HOME/.config/omarchy/themes/seasons/backgrounds"

# Map season to default month and wallpaper
get_wallpaper() {
  local month=$1
  case $month in
    1)  echo "01-january-winter.jpg" ;;
    2)  echo "02-february-winter.jpg" ;;
    3)  echo "03-march-spring.jpg" ;;
    4)  echo "04-april-spring.jpg" ;;
    5)  echo "05-may-spring.jpg" ;;
    6)  echo "06-june-summer.jpg" ;;
    7)  echo "07-july-summer.jpg" ;;
    8)  echo "08-august-summer.jpg" ;;
    9)  echo "09-september-autumn.jpg" ;;
    10) echo "10-october-autumn.jpg" ;;
    11) echo "11-november-autumn.jpg" ;;
    12) echo "12-december-winter.jpg" ;;
  esac
}

set_wallpaper() {
  local month=$1
  local wp=$(get_wallpaper $month)
  local path="$THEME_DIR/$wp"
  if [ -f "$path" ]; then
    omarchy-theme-bg-set "$path"
    echo "Wallpaper: $wp"
  fi
}

case "${1:-}" in
  cycle)
    result=$(omarchy-shell -q seasons cycle)
    echo "$result"
    # Also cycle the wallpaper
    case "$result" in
      *winter) set_wallpaper 1 ;;
      *spring) set_wallpaper 4 ;;
      *summer) set_wallpaper 7 ;;
      *autumn) set_wallpaper 10 ;;
    esac
    ;;
  winter|spring|summer|autumn)
    omarchy-shell -q seasons set "$1"
    echo "Season: $1"
    case "$1" in
      winter) set_wallpaper 1 ;;
      spring) set_wallpaper 4 ;;
      summer) set_wallpaper 7 ;;
      autumn) set_wallpaper 10 ;;
    esac
    ;;
  reset)
    omarchy-shell -q seasons reset
    month=$(date +%-m)
    set_wallpaper $month
    echo "Reset to automatic (month $month)"
    ;;
  *)
    month=$(date +%-m)
    set_wallpaper $month
    echo "Set to current month: $month"
    ;;
esac
