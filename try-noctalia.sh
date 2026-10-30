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
for file in flake.nix flake.lock desktop/home.nix desktop/services.nix desktop/shell.nix; do
  install -Dm644 "$repo/$file" "$stage/$file"
done
# Do not modify /etc/nixos or activate anything until the trial builds.
nix build "path:$stage#nixosConfigurations.nixos.config.system.build.toplevel" --no-link \
  --option extra-substituters https://noctalia.cachix.org \
  --option extra-trusted-public-keys noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=
for file in flake.nix flake.lock desktop/home.nix desktop/services.nix desktop/shell.nix; do
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
echo 'To restore Waybar: set useNoctalia = false in /etc/nixos/desktop/shell.nix and rebuild.'
