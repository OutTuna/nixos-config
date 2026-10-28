{ ... }:

{
  imports = [
    ./theme
    ./hyprland
    ./waybar
    ./terminal
    ./fish.nix
    ./browser.nix
    ./services.nix
  ];

  home.username = "zei";
  home.homeDirectory = "/home/zei";
  home.stateVersion = "26.05";
}
