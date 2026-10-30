#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run: sudo bash $0" >&2; exit 1; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mkdir -p /var/backups
backup=$(mktemp -d /var/backups/nixos-before-noctalia-XXXXXXXX)
tar --exclude=./backups -czf "$backup/nixos.tar.gz" -C /etc/nixos .
readlink -f /nix/var/nix/profiles/system > "$backup/system-path"
echo "Backup: $backup/nixos.tar.gz"
for directory in .config/noctalia .local/state/noctalia .local/share/noctalia; do
  if [[ -d "/home/zei/$directory" ]]; then
    tar -czf "$backup/$(echo "$directory" | tr / _).tar.gz" -C /home/zei "$directory"
  fi
done
stage=$(mktemp -d /tmp/opencode/noctalia-apply-XXXXXXXX)
tar -xzf "$backup/nixos.tar.gz" -C "$stage"
files=(flake.nix flake.lock configuration.nix modules/programs.nix
  desktop/home.nix desktop/services.nix desktop/shell.nix
  desktop/theme/cursor.nix desktop/hyprland/default.nix desktop/hyprland/appearance.nix)
for file in "${files[@]}"; do
  install -Dm644 "$repo/$file" "$stage/$file"
done
# Do not modify /etc/nixos or activate anything until the trial builds.
nix build "path:$stage#nixosConfigurations.nixos.config.system.build.toplevel" --no-link \
  --option extra-substituters https://noctalia.cachix.org \
  --option extra-trusted-public-keys noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=
for file in "${files[@]}"; do
  install -Dm644 "$repo/$file" "/etc/nixos/$file"
done
# v4's QML plugins/JSON and template TOML are not v5 configuration. Preserve
# the entire legacy directory, rather than letting v5 interpret mixed files.
if [[ -f /home/zei/.config/noctalia/settings.json && ! -e /home/zei/.config/noctalia/config.toml ]]; then
  legacy=$(mktemp -d /home/zei/.config/noctalia-v4-backup-XXXXXXXX)
  rmdir "$legacy"
  mv /home/zei/.config/noctalia "$legacy"
  echo "Legacy Noctalia config/plugins preserved: $legacy"
fi
nixos-rebuild switch --flake /etc/nixos#nixos
# Preserve obsolete, unmanaged KDE/theme settings outside ~/.config. Do not
# remove arbitrary Qt libraries: SDDM and non-KDE applications still need Qt.
obsolete=(Kvantum kdeglobals kglobalshortcutsrc kwinrc kwinoutputconfig.json
  plasmashellrc plasma-org.kde.plasma.desktop-appletsrc dolphinrc konsolerc
  konsolesshconfig arkrc kded5rc kded6rc kactivitymanagerdrc
  kactivitymanagerd-statsrc systemd/user/gruvbox-wallpaper.service.d)
for relative in "${obsolete[@]}"; do
  source="/home/zei/.config/$relative"
  if [[ -e "$source" || -L "$source" ]]; then
    mkdir -p "$backup/obsolete-config/$(dirname "$relative")"
    mv "$source" "$backup/obsolete-config/$relative"
  fi
done
# Plain Hyprland may not have graphical-session.target active. exec-once will
# handle future logins; explicitly start the new service for this live session.
runtime="/run/user/$(id -u zei)"
if [[ -S "$runtime/bus" ]]; then
  runuser -u zei -- env XDG_RUNTIME_DIR="$runtime" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
    systemctl --user unset-environment QT_STYLE_OVERRIDE QT_QPA_PLATFORMTHEME
  runuser -u zei -- env XDG_RUNTIME_DIR="$runtime" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
    systemctl --user start noctalia.service
  runuser -u zei -- env XDG_RUNTIME_DIR="$runtime" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
    /etc/profiles/per-user/zei/bin/noctalia msg config-set wallpaper.enabled true
fi
echo 'To restore Waybar: set useNoctalia = false in /etc/nixos/desktop/shell.nix and rebuild.'
