{ pkgs, ... }:

let p = import ../theme/palette.nix;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "${pkgs.fish}/bin/fish";
        font = "JetBrainsMono Nerd Font:size=16";
        pad = "12x12";
      };
      scrollback.lines = 10000;
      colors-dark = p.terminal // { alpha = 0.66; };
    };
  };
}
