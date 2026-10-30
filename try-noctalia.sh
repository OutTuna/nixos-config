#!/usr/bin/env bash
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "Run: sudo bash $0" >&2; exit 1; }
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mkdir -p /var/backups
backup=$(mktemp -d /var/backups/nixos-before-noctalia-XXXXXXXX)
tar --exclude=./backups -czf "$backup/nixos.tar.gz" -C /etc/nixos .
readlink -f /nix/var/nix/profiles/system > "$backup/system-path"
echo "Backup: $backup/nixos.tar.gz"
for file in desktop/home.nix desktop/services.nix desktop/shell.nix; do
  install -Dm644 "$repo/$file" "/etc/nixos/$file"
done
nixos-rebuild build --flake /etc/nixos#nixos
nixos-rebuild switch --flake /etc/nixos#nixos
echo 'To restore Waybar: set useNoctalia = false in /etc/nixos/desktop/shell.nix and rebuild.'
