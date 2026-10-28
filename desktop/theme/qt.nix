{ pkgs, ... }:

{
  # Matching Gruvbox for our Qt apps (e.g. Dolphin), in addition to upstream GTK.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "kvantum";
    kvantum = {
      enable = true;
      themes = [ (pkgs.gruvbox-kvantum.override { variant = "Gruvbox-Dark-Green"; }) ];
      settings.General.theme = "Gruvbox-Dark-Green";
    };
  };
}
