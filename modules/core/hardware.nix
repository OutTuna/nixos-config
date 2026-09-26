{ config, ... }:
{

  hardware.graphics = {
	enable = true;
	enable32Bit = true;

  };
  hardware.nvidia= {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.enableRedistributableFirmware = true;
}
