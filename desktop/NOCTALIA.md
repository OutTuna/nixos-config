# Noctalia trial

The locked nixpkgs provides Noctalia 4.7.7 (Quickshell). No extra flake input or
system-wide dependency update is needed. `shell.nix` owns its settings and service.
Waybar and Mako are disabled during the trial, not removed from the configuration.
Existing wallpaper, Hypridle, Hyprlock and keyboard bindings remain unchanged.

Apply to the existing installation:

```sh
sudo bash ~/Projects/nixos-restore/try-noctalia.sh
```

The script first backs up `/etc/nixos` (excluding old backups) and records the
current system path under `/var/backups/nixos-before-noctalia-*`. It only installs
the three Home Manager files needed for the trial, preserving other local modules.

## Reproducibility

Change settings in `desktop/shell.nix`, then rebuild. The service copies the
Nix-generated JSON to a private runtime file on every start. GUI changes are
temporary and reset on restart/login. This permits Noctalia's normal runtime
writes without allowing them to become a second configuration source.
Weather/geolocation, telemetry, automatic plugin updates and external app theming
are disabled. Bluetooth, networking and audio controls are on the panel.

## Restore Waybar

Set `useNoctalia = false;` in `/etc/nixos/desktop/shell.nix`, then run:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

If switching does not replace the panel immediately, log out and back in.
The pre-trial system generation is also available in the boot menu.
