{ lib, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
    # KDE layout: Xiaomi on the left, Samsung to its right, aligned at the top.
    "DP-1,2560x1440@200,0x0,1"
    "HDMI-A-1,1920x1080@71.91,2560x0,1"
    ",preferred,auto,1"
    ];
    workspace = [ "1, monitor:DP-1, default:true" ];
    cursor.default_monitor = "DP-1";
    "exec-once" = lib.mkBefore [ "${pkgs.hyprland}/bin/hyprctl dispatch focusmonitor DP-1" ];
  };
}
