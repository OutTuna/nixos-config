{ pkgs, ... }:

{
  home-manager.users.zei.imports = [ ./neovim ];

  # Mason downloads upstream Linux executables rather than Nix packages.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ stdenv.cc.cc zlib openssl libxml2 ncurses ];
  };

  environment.systemPackages = with pkgs; [
    opencode
    git
    gh
    ripgrep
    fd
  ];

  # Also make nvim available to sudo for system-config editing.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  # Docker includes Compose. Membership grants root-equivalent access.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  users.users.zei.extraGroups = [ "docker" ];
}
