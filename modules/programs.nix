{ pkgs, ... }:

{
  # General applications; development tools live in coding.nix.
  environment.systemPackages = with pkgs; [
    (callPackage ../desktop/helium.nix { })
    
    #system-stuff
    foot
    fastfetch
    fuzzel
    waybar
    mako
    hyprlock
    hypridle
    hyprpolkitagent
    wl-clipboard
    grim
    slurp
    brightnessctl
    pavucontrol
    networkmanagerapplet
    kdePackages.dolphin
    kdePackages.kate

    #default
    telegram-desktop
    discord
    vesktop
    qbittorrent

    #music-stuff
    kew
  ];

  # Installs Steam and enables its required 32-bit graphics and hardware rules.
  programs.steam.enable = true;

  programs.fish.enable = true;
  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };
}
