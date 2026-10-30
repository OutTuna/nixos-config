{ lib, pkgs, ... }:
let
  # false restores Waybar + Mako without deleting their configuration.
  useNoctalia = true;
in lib.mkIf useNoctalia {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;

  # Official upstream module/package, pinned in flake.lock. No source patches.
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      shell.font_family = "JetBrainsMono Nerd Font";
      shell.setup_wizard_enabled = false;
      shell.launch_apps_as_systemd_services = true;
      theme.mode = "dark";
      # Keep the existing wallpaper and Hypridle during the version migration.
      wallpaper.enabled = false;
      idle.behavior.lock.enabled = false;
      idle.behavior.screen-off.enabled = false;
    };
  };

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
    Conflicts = [ "waybar-recovery.service" "noctalia-fixed-preview.service" ];
  };
}
