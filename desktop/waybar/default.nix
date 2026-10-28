{ pkgs, ... }:

{
  imports = [ ./extras ./style.nix ];
  programs.waybar = {
    enable = true;
    systemd = { enable = true; targets = [ "graphical-session.target" ]; };
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 16;
      modules-left = [ "custom/apps" "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "hyprland/language" "cpu" "memory" "pulseaudio" "network" "battery" "tray" ];
      "custom/apps" = {
        format = "";
        tooltip-format = "Applications (Win+X)";
        on-click = "${pkgs.fuzzel}/bin/fuzzel";
      };
      "hyprland/workspaces" = {
        on-click = "activate";
        format = "{icon}";
        format-icons = { default = ""; active = ""; urgent = ""; };
        persistent-workspaces."*" = 5;
      };
      "hyprland/language" = {
        # Custom format-en/ru values are passed as a positional argument by Waybar.
        format = "  {}";
        format-en = "EN";
        format-ru = "RU";
        keyboard-name = "sonix-ak820";
        on-click = "${pkgs.hyprland}/bin/hyprctl switchxkblayout sonix-ak820 next";
      };
      clock = { format = "  {:%a %d %b  %H:%M}"; tooltip-format = "<tt>{calendar}</tt>"; };
      cpu.format = "  {usage}%";
      memory.format = "  {percentage}%";
      pulseaudio = {
        format = "{icon}  {volume}%";
        format-icons = { headphone = ""; default = [ "" "" "" ]; };
        format-muted = "";
        on-click = "pavucontrol";
      };
      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "󰈀";
        format-disconnected = "󰖪";
        tooltip-format = "{essid} {ipaddr}";
        on-click = "nm-connection-editor";
      };
      battery = {
        format = "{icon}  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        format-charging = "  {capacity}%";
        states = { warning = 25; critical = 10; };
      };
      tray.spacing = 8;
    };
  };
}
