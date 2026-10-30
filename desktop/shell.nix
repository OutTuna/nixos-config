{ config, lib, pkgs, ... }:
let
  # false restores Waybar + Mako without deleting their configuration.
  useNoctalia = true;
in lib.mkIf useNoctalia {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;
  programs.fuzzel.enable = lib.mkForce false;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "thunar.desktop" ];
      "application/pdf" = [ "org.gnome.Papers.desktop" ];
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
    };
  };

  # Official upstream module/package, pinned in flake.lock. No source patches.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      # Keep track titles out of the bar; playback stays available in the media panel.
      bar.default.end = [
        "tray" "notifications" "clipboard" "network" "bluetooth"
        "volume" "brightness" "battery" "control-center" "session"
      ];
      shell.font_family = "JetBrainsMono Nerd Font";
      shell.setup_wizard_enabled = false;
      shell.launch_apps_as_systemd_services = true;
      theme.mode = "dark";
      theme.templates = {
        enable_builtin_templates = true;
        builtin_ids = [ "hyprland" "foot" "gtk3" "gtk4" "qt" ];
      };
      wallpaper.enabled = true;
      wallpaper.directory = "/home/zei/Pictures";
      idle.behavior.lock.enabled = false;
      idle.behavior.screen-off.enabled = false;
    };
  };

  home.packages = [ pkgs.adw-gtk3 ];
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings.Appearance = {
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
      style = "Fusion";
    };
    qt6ctSettings.Appearance = {
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
      style = "Fusion";
    };
  };
  # These are mutable outputs, not store symlinks. Seed them on a clean install
  # so Hyprland/Foot can start before the first palette is generated.
  home.activation.seedNoctaliaTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${config.xdg.configHome}/hypr" "${config.xdg.configHome}/foot/themes"
    if [ ! -e "${config.xdg.configHome}/hypr/noctalia.conf" ]; then
      run cp ${pkgs.writeText "noctalia-hyprland-fallback.conf" ''
        general {
          col.active_border = rgb(abb2bf)
          col.inactive_border = rgb(282c34)
        }
      ''} "${config.xdg.configHome}/hypr/noctalia.conf"
      run chmod u+w "${config.xdg.configHome}/hypr/noctalia.conf"
    fi
    if [ ! -e "${config.xdg.configHome}/foot/themes/noctalia" ]; then
      run cp ${pkgs.writeText "noctalia-foot-fallback" ''
        [colors-dark]
        foreground=abb2bf
        background=282c34
      ''} "${config.xdg.configHome}/foot/themes/noctalia"
      run chmod u+w "${config.xdg.configHome}/foot/themes/noctalia"
    fi
  '';

  # v5 persists GUI overrides in ~/.local/state/noctalia/settings.toml.
  # Do not copy/reset that file at login; the Nix config is only the base layer.
  wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
    "${pkgs.writeShellScript "autostart-noctalia" ''
      ${pkgs.systemd}/bin/systemctl --user import-environment \
        WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP
      ${pkgs.systemd}/bin/systemctl --user start noctalia.service
    ''}"
  ];
  systemd.user.services.noctalia.Unit = {
    ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
    Conflicts = [ "waybar-recovery.service" "noctalia-fixed-preview.service" "mako.service" "gruvbox-wallpaper.service" ];
  };
}
