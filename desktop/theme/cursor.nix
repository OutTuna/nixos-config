{ pkgs, ... }:
{
  # A complete scalable icon set is still needed after removing Plasma/Breeze.
  # This does not set GTK colors or interfere with Noctalia's generated CSS.
  gtk = {
    enable = true;
    iconTheme = { name = "Papirus-Dark"; package = pkgs.papirus-icon-theme; };
  };
  dconf.settings."org/gnome/desktop/interface".icon-theme = "Papirus-Dark";
  # Only the pointer is managed here. No forced GTK/Qt/Kvantum theme;
  # Noctalia may generate application themes without Nix resetting them.
  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
