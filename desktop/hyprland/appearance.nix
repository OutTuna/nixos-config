{ config, lib, pkgs, ... }:

let p = import ../theme/palette.nix;
in
{
  wayland.windowManager.hyprland.settings = {
    "exec-once" = [ "${pkgs.hyprland}/bin/hyprctl setcursor Bibata-Modern-Ice 24" ];
    general = {
      gaps_in = 6;
      gaps_out = 12;
      border_size = 2;
    };
    misc.background_color = "rgb(${p.background})";
    decoration = {
      rounding = 0;
      blur = {
        enabled = true;
        size = 3;
        noise = 0;
        passes = 2;
        contrast = 1.4;
        brightness = 1;
        xray = true;
      };
      shadow = {
        enabled = true;
        range = 20;
        render_power = 3;
        offset = "0 2";
        color = "rgba(00000055)";
      };
    };
  };
  # Appended after the declarative settings, so Noctalia owns border colors.
  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''
    source = ${config.xdg.configHome}/hypr/noctalia.conf
  '';
}
