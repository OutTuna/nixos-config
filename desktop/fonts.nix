{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      public-sans
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrains Mono" "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Public Sans" ];
        serif = [ "Noto Serif" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
