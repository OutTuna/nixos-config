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
      # XKB keysyms change with the active layout: V becomes Cyrillic_em.
      key-bindings.clipboard-paste =
        "Control+v Control+Cyrillic_em Control+Shift+v Control+Shift+Cyrillic_em XF86Paste";
      scrollback.lines = 10000;
      # Palette comes from Noctalia; keep terminal behavior in Nix.
      colors-dark.alpha = 0.95;
    };
  };
}
