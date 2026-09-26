{ pkgs, ... }:
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # Основной монитор (Xiaomi): 2560x1440@200, позиция 0x0, 1 (главный)
      "DP-1, 2560x1440@200, 0x0, 1"
      
      # Второй монитор: 1920x1080@60, позиция 2560x-720 (справа и выше), 1 (включен)
      "HDMI-A-1, 1920x1080@60, 2560x-720, 1"
    ];

    extraConfig = ''
      #hyprlang noerror true
      source = ~/.config/hypr/monitors.conf
      source = ~/.config/hypr/workspaces.conf
      # hyprlang noerror false
    '';
  };

  home.packages = with pkgs; [ nwg-displays ];
}
