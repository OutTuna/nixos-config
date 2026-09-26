{ inputs, pkgs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = false;
  };

  home.packages = [
    inputs.helium.packages.${pkgs.system}.default
  ];
}
