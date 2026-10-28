{ config, pkgs, ... }:

{
  imports = [ ./fonts.nix ./sddm.nix ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  # RTX 5070 (Blackwell) requires NVIDIA's open kernel module.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    # NVIDIA suspend/resume support and VRAM preservation for automatic sleep.
    powerManagement.enable = true;
    # Latest non-beta branch in the locked nixpkgs (currently 615.78.08).
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
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
