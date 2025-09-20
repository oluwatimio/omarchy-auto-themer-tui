#!/bin/bash

set -euo pipefail

DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

APP_NAME="Omarchy Auto Themer"
BIN_DIR="$HOME/.local/bin"
APP_BIN="$BIN_DIR/omarchy-auto-themer"
BACKEND_BIN="$BIN_DIR/omarchy-theme-auto"

ICON_DIR="$HOME/.local/share/applications/icons"
ICON_DST="$ICON_DIR/${APP_NAME}.svg"

DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/${APP_NAME}.desktop"

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

USER_CONF="$HOME/.config/auto-themer/theme-auto.conf"
DEFAULT_CONF_SRC="$DIR/config/theme-auto.conf"

echo "Installing binaries to $BIN_DIR..."
mkdir -p "$BIN_DIR"
install -m 0755 "$DIR/omarchy-auto-themer" "$APP_BIN"
install -m 0755 "$DIR/omarchy-theme-auto" "$BACKEND_BIN"

echo "Installing icon to $ICON_DST..."
mkdir -p "$ICON_DIR"
install -m 0644 "$DIR/icon.svg" "$ICON_DST"

echo "Installing systemd user units..."
mkdir -p "$SYSTEMD_USER_DIR"
install -m 0644 "$DIR/systemd/omarchy-theme-auto.service" "$SYSTEMD_USER_DIR/omarchy-theme-auto.service"
install -m 0644 "$DIR/systemd/omarchy-theme-auto.timer"   "$SYSTEMD_USER_DIR/omarchy-theme-auto.timer"
install -m 0644 "$DIR/systemd/omarchy-theme-auto.path"    "$SYSTEMD_USER_DIR/omarchy-theme-auto.path"

echo "Ensuring user config exists..."
if [[ ! -f "$USER_CONF" ]]; then
  mkdir -p "$(dirname "$USER_CONF")"
  install -m 0644 "$DEFAULT_CONF_SRC" "$USER_CONF"
  echo "  Created $USER_CONF from template"
else
  echo "  User config already present at $USER_CONF (left unchanged)"
fi

echo "Creating launcher at $DESKTOP_FILE..."
mkdir -p "$DESKTOP_DIR"

# Choose a terminal to run the TUI
TERMINAL_BIN="${TERMINAL:-}"
if [[ -z "$TERMINAL_BIN" ]]; then
  if command -v alacritty &>/dev/null; then TERMINAL_BIN=alacritty; \
  elif command -v kitty &>/dev/null; then TERMINAL_BIN=kitty; \
  elif command -v wezterm &>/dev/null; then TERMINAL_BIN=wezterm; \
  else TERMINAL_BIN=xterm; fi
fi


# Build Exec command appropriate for the terminal
case "$TERMINAL_BIN" in
  alacritty)
    EXEC_CMD="$TERMINAL_BIN --class TUI.float -e $APP_BIN"
    ;;
  kitty)
    EXEC_CMD="$TERMINAL_BIN --class TUI.float -e $APP_BIN"
    ;;
  wezterm)
    EXEC_CMD="$TERMINAL_BIN start --class TUI.float -- $APP_BIN"
    ;;
  ghostty)
    EXEC_CMD="$TERMINAL_BIN -e $APP_BIN"
    ;;
  *)
    EXEC_CMD="$TERMINAL_BIN -e $APP_BIN"
    ;;
esac

cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=Configure automatic day/night theme switching
Exec=$EXEC_CMD
Terminal=false
Type=Application
Icon=$ICON_DST
StartupNotify=true
Categories=Settings;Utility;
EOF

chmod +x "$DESKTOP_FILE"

echo "Reloading systemd user daemon and enabling units..."
systemctl --user daemon-reload || true
systemctl --user enable --now omarchy-theme-auto.timer || true
systemctl --user enable --now omarchy-theme-auto.path || true

echo
echo "Installation complete!"
echo "- Run from terminal: omarchy-auto-themer"
echo "- Or launch from app menu: $APP_NAME"
echo "- Units: omarchy-theme-auto.timer (minutely), omarchy-theme-auto.path (on config change)"
echo
