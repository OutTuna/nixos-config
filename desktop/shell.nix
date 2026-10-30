{ config, lib, pkgs, ... }:
let
  # Set to false and rebuild to restore Waybar + Mako.
  useNoctalia = true;
  settings = pkgs.writeText "noctalia-settings.json" (builtins.toJSON {
    settingsVersion = 59; # Schema of the locked noctalia-shell 4.7.7.
    bar = {
      position = "top";
      density = "compact";
      widgets = {
        left = map (id: { inherit id; }) [ "Launcher" "Workspace" "ActiveWindow" ];
        center = [ { id = "Clock"; } ];
        right = map (id: { inherit id; }) [
          "SystemMonitor" "Tray" "Volume" "Network" "Bluetooth"
          "NotificationHistory" "ControlCenter"
        ];
      };
    };
    general = { telemetryEnabled = false; showChangelogOnStartup = false; };
    ui = { fontDefault = "JetBrainsMono Nerd Font"; fontFixed = "JetBrainsMono Nerd Font"; };
    wallpaper.enabled = false;
    dock.enabled = false;
    idle.enabled = false;
    location = { weatherEnabled = false; autoLocate = false; };
    colorSchemes = { darkMode = true; useWallpaperColors = false; syncGsettings = false; };
    templates.enableUserTheming = false;
    appLauncher.terminalCommand = "${pkgs.foot}/bin/foot -e";
    hooks = { enabled = true; screenLock = "${pkgs.hyprlock}/bin/hyprlock"; };
    plugins.autoUpdate = false;
  });
  start = pkgs.writeShellScript "start-noctalia" ''
    # GUI edits are temporary: Nix settings are restored on each service start.
    install -Dm600 ${settings} "$XDG_RUNTIME_DIR/noctalia/settings.json"
    export NOCTALIA_SETTINGS_FILE="$XDG_RUNTIME_DIR/noctalia/settings.json"
    exec ${pkgs.noctalia-shell}/bin/noctalia-shell
  '';
in lib.mkIf useNoctalia {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;
  home.packages = [ pkgs.noctalia-shell ];
  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia desktop shell (Nix-managed)";
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      X-Restart-Triggers = [ "${settings}" ];
    };
    Service = { ExecStart = "${start}"; Restart = "on-failure"; RestartSec = 3; };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
