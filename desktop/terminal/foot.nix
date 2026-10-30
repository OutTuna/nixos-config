{ config, pkgs, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        include = "${config.xdg.configHome}/foot/themes/noctalia";
        shell = "${pkgs.fish}/bin/fish";
        font = "JetBrainsMono Nerd Font:size=16";
        pad = "12x12";
      };
      scrollback.lines = 10000;
      # Palette comes from Noctalia; keep terminal behavior in Nix.
      colors-dark.alpha = 0.66;
    };
  };
}
