{ pkgs, ... }:
{
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
