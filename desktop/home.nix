{ ... }:

{
  imports = [
    ./theme/cursor.nix
    ./hyprland
    ./waybar
    ./terminal
    ./fish.nix
    ./browser.nix
    ./services.nix
    ./shell.nix
  ];

  home.username = "zei";
  home.homeDirectory = "/home/zei";
  home.stateVersion = "26.05";
}
