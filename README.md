# Omarchy Auto Themer (Standalone Bundle)

A small TUI + systemd setup to automatically switch between a Light and Dark Omarchy theme based on time. Includes:

- Standalone TUI: `omarchy-auto-themer`
- Backend: `omarchy-theme-auto`
- User systemd units: service, timer (minutely), and path watcher
- Default config template and an app launcher with icon

## Requirements

- Arch/Wayland with Hyprland (uses `hyprctl`, `omarchy-theme-set`)
- `systemd --user`
- `gum` (for the TUI)

## Install

From the repo:

```
bash install.sh
```

Installs to your home:

- Binaries: `~/.local/bin/omarchy-auto-themer`, `~/.local/bin/omarchy-theme-auto`
- Units: `~/.config/systemd/user/omarchy-theme-auto.{service,timer,path}` (enabled)
- Config: creates `~/.config/auto-themer/theme-auto.conf` if missing
- Launcher + icon: `~/.local/share/applications/Omarchy Auto Themer.desktop` and `~/.local/share/applications/icons/Omarchy Auto Themer.svg`

To update, re-run the installer — it overwrites binaries and units, leaves config.

## Use

- Launch: `omarchy-auto-themer` or via app menu (Omarchy Auto Themer)
- Configure:
  - Toggle Enabled
  - Pick Light/Dark themes (from `omarchy-theme-list`)
  - Set Day/Night start times
  - Apply Now / Show Status
  - Enable/Disable Timer + Watcher

Config precedence is user-first, default-fallback:

- User file: `~/.config/auto-themer/theme-auto.conf`
- Default: `~/.local/share/omarchy/config/auto-themer/theme-auto.conf`

Edits to either file apply immediately (watched by the `.path` unit).

## Uninstall

s
From your project folder (if you moved it):

```
bash uninstall.sh [--keep-units] [--purge]
```

- Removes binaries, launcher, and icon
- Disables and removes units (unless `--keep-units`)
- `--purge` also removes `~/.config/auto-themer/theme-auto.conf`

## Verify

- Timer: `systemctl --user list-timers omarchy-theme-auto.timer`
- Watcher: `systemctl --user status omarchy-theme-auto.path`
- Logs: `journalctl --user -u omarchy-theme-auto.service -e -n 50`

## Troubleshooting

- Ensure `~/.local/bin` is in PATH. Example:
  - `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc`
- Make sure `gum` is installed (`sudo pacman -S gum`).
- Hyprland must be running; no `DISPLAY` override is needed.
- If the launcher opens in the wrong terminal, re-run the installer to refresh it.
