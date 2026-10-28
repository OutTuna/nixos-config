{ pkgs, ... }:

{
  # LazyVim/lazy.nvim own ~/.config/nvim and plugin downloads.
  # Do not generate init.lua or a second set of Nix-managed plugins.
  programs.neovim.enable = false;
  # Seed a writable LazyVim config once; lazy.nvim updates its lockfile itself.
  home.activation.seedLazyVim = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -e "$HOME/.config/nvim" ]; then
        run mkdir -p "$HOME/.config"
        run cp -R ${../../dotfiles/nvim} "$HOME/.config/nvim"
        run chmod -R u+w "$HOME/.config/nvim"
      fi
    '';
  };
  home.packages = with pkgs; [
    neovim git ripgrep fd fzf lazygit wl-clipboard
    gcc gnumake tree-sitter curl wget unzip gnutar gzip
    nodejs python3 python3Packages.pip
  ];
}
