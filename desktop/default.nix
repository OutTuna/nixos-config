{ pkgs, ... }:

{
  imports = [ ./fonts.nix ./sddm.nix ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  users.users.zei.shell = pkgs.fish;
  services.displayManager.defaultSession = "hyprland-uwsm";
  security.pam.services.hyprlock = { };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "before-home-manager";
    users.zei = import ./home.nix;
  };
}
