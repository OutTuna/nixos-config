{ pkgs, ... }:

let
  loginctl = "${pkgs.systemd}/bin/loginctl";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
        # Wait for the compositor's lock notification before allowing suspend.
        inhibit_sleep = 3;
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
        ignore_wayland_inhibit = false;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "${loginctl} lock-session && ${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 600;
          on-timeout = "${systemctl} suspend";
        }
      ];
    };
  };
}
