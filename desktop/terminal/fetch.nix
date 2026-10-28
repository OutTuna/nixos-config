{ pkgs, ... }:

let
  themedFetch = pkgs.callPackage ./fetch-package.nix { };
  nixLogo = pkgs.runCommand "fetch-nixos-logo" { nativeBuildInputs = [ pkgs.fastfetch ]; } ''
    fastfetch --config none --logo NixOS --structure Break --pipe true \
      --logo-padding-left 0 --logo-padding-top 0 --logo-padding-right 0 > "$out"
  '';
in
{
  # The real animated 3D fetch, not an alias or a custom fastfetch animation.
  home.packages = [ themedFetch ];
  # NixOS snowflake, rendered in 3D by fetch itself.
  xdg.configFile."fetch/logo.txt".source = nixLogo;
  xdg.configFile."fetch/config".text = ''
    os
    kernel
    packages
    shell
    wm
    theme
    icons
    cursor
    font
    terminal
    host
    display
    cpu
    gpu
    memory
    disk
    uptime
    colors
    spin=xy
    speed=0.6
    label_color=yellow
    separator=▔
    logo_outer=38;2;82;119;195
    logo_inner=38;2;126;186;228
  '';
}
