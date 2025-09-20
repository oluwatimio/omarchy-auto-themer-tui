#!/bin/bash

set -euo pipefail

KEEP_UNITS=false
PURGE_CONFIG=false

for arg in "$@"; do
  case "$arg" in
    --keep-units) KEEP_UNITS=true ;;
    --purge) PURGE_CONFIG=true ;;
    -h|--help)
      cat <<USAGE
Usage: $0 [--keep-units] [--purge]

Removes the installed Auto Themer TUI, backend, launcher, and icon.

Options:
  --keep-units  Do not disable/remove systemd user units
  --purge       Also remove user config at ~/.config/auto-themer/theme-auto.conf
USAGE
      exit 0
      ;;
  esac
done

BIN_DIR="$HOME/.local/bin"
APP_BIN="$BIN_DIR/omarchy-auto-themer"
BACKEND_BIN="$BIN_DIR/omarchy-theme-auto"

DESKTOP_DIR="$HOME/.local/share/applications"
APP_NAME="Omarchy Auto Themer"
DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME}.desktop"

ICON_DIR="$HOME/.local/share/applications/icons"
ICON_FILE="$ICON_DIR/${APP_NAME}.svg"

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_USER_DIR/omarchy-theme-auto.service"
TIMER_FILE="$SYSTEMD_USER_DIR/omarchy-theme-auto.timer"
PATH_FILE="$SYSTEMD_USER_DIR/omarchy-theme-auto.path"

USER_CONF="$HOME/.config/auto-themer/theme-auto.conf"

echo "Uninstalling Auto Themer..."

if [[ "$KEEP_UNITS" == false ]]; then
  systemctl --user disable --now omarchy-theme-auto.timer 2>/dev/null || true
  systemctl --user disable --now omarchy-theme-auto.path 2>/dev/null || true
  rm -f "$SERVICE_FILE" "$TIMER_FILE" "$PATH_FILE"
  systemctl --user daemon-reload 2>/dev/null || true
  echo "- Disabled and removed systemd user units"
else
  echo "- Keeping systemd user units (per --keep-units)"
fi

rm -f "$APP_BIN" "$BACKEND_BIN"
echo "- Removed binaries from $BIN_DIR"

rm -f "$DESKTOP_FILE" "$ICON_FILE"
echo "- Removed launcher and icon"

if [[ "$PURGE_CONFIG" == true ]]; then
  rm -f "$USER_CONF"
  echo "- Removed user config $USER_CONF"
else
  echo "- Kept user config at $USER_CONF (use --purge to remove)"
fi

echo "Uninstall complete."

