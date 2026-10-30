{ config, pkgs, ... }:

{
  # Kernel 7.3.0 in the pinned nixpkgs; keep the NVIDIA module on the same kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # OpenRazer backend for the Noctalia Razer Devices plugin.
  hardware.openrazer = {
    enable = true;
    users = [ "zei" ];
    # This nixpkgs driver install phase omits the per-module certificates
    # required by the kernel module aggregator. Sign after stripping.
    packages.kernel = config.boot.kernelPackages.openrazer.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        for module in "$out"/lib/modules/*/kernel/drivers/hid/*.ko; do
          ${pkgs.buildPackages.kmodigest}/bin/kmodigest "$module"
          test -s "$module.cer"
        done
      '';
    });
  };

}
