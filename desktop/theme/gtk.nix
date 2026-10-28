{ lib, pkgs, ... }:

let
  name = "Colloid-Green-Dark-Gruvbox";
  theme = pkgs.colloid-gtk-theme.override {
    colorVariants = [ "dark" ];
    themeVariants = [ "green" ];
    tweaks = [ "gruvbox" "rimless" "float" ];
  };
in
{
  gtk = {
    enable = true;
    font = { name = "JetBrains Mono"; size = 12; };
    theme = { inherit name; package = theme; };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "green"; };
    };
    cursorTheme = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = lib.mkForce true;
    gtk4 = {
      theme = { inherit name; package = theme; };
      extraConfig.gtk-application-prefer-dark-theme = lib.mkForce true;
    };
  };
  dconf.settings."org/gnome/desktop/interface" = {
    gtk-theme = name;
    icon-theme = "Papirus-Dark";
    color-scheme = "prefer-dark";
    font-name = "JetBrains Mono 12";
    monospace-font-name = "JetBrains Mono 11";
    cursor-theme = "breeze_cursors";
    cursor-size = 24;
  };
  home.pointerCursor = {
    enable = true;
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = false;
  };
}
