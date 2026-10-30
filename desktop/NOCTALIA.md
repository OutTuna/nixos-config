# Noctalia v5

Noctalia 5.4.1 is pinned as an official flake input, with upstream's own locked
nixpkgs dependency set. The rest of the system keeps its existing nixpkgs pin.
The official Home Manager module installs the package and systemd service.
There are no Qt, Quickshell or plugin source patches. The upstream Cachix key
is configured in `flake.nix`.

## Apply

```sh
sudo bash ~/Projects/nixos-restore/try-noctalia.sh
```

The script backs up `/etc/nixos`, the current system path and Noctalia's user
configuration/state under `/var/backups/nixos-before-noctalia-*`. It builds a
staging configuration **before** changing `/etc/nixos`. Only the flake files and
three relevant desktop modules are installed; other local modules are preserved.

The legacy v4 config directory, including QML plugins, is moved intact to
`~/.config/noctalia-v4-backup-*` on the first migration. Reinstall compatible v5
plugins through Noctalia rather than copying v4 QML plugins into the new shell.

## Settings and autostart

`desktop/shell.nix` declares the package, autostart and baseline settings. GUI
changes persist in `~/.local/state/noctalia/settings.toml` and override the Nix
base configuration. They are **not reset at login**. To reproduce a GUI-tuned
layout, export/review the config and translate desired values back into the Nix
settings. Do not publish raw exports: they may contain plugin credentials.

Existing wallpaper, Hypridle, Hyprlock and application keybindings are preserved.
Noctalia autostarts both in plain Hyprland and in UWSM-managed sessions.

```sh
noctalia msg settings-toggle
noctalia msg panel-toggle control-center
```

## Restore Waybar

Set `useNoctalia = false;` in `/etc/nixos/desktop/shell.nix`, then run:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

The previous system generation and full pre-migration backups are also retained.
