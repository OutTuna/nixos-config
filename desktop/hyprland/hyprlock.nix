{ pkgs, ... }:

let
  p = import ../theme/palette.nix;
  wallpaper = import ../theme/wallpaper-source.nix { inherit pkgs; };
  label = {
    monitor = "";
    halign = "center";
    valign = "center";
    font_family = "JetBrains Mono";
    color = "rgb(${p.text})";
    shadow_passes = 2;
    shadow_size = 3;
  };
in
{
  # Layout inspired by MrVivekRajan/Hyprlock-Styles, Style-7.
  # Use the freely licensed Syncopate instead of redistributing StretchPro/SF Pro.
  home.packages = [ (pkgs.google-fonts.override { fonts = [ "Syncopate" ]; }) ];
  fonts.fontconfig.enable = true;

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };
      background = [{
        monitor = "";
        path = "${wallpaper}";
        color = "rgb(${p.background})";
        blur_passes = 1;
        blur_size = 3;
        brightness = 0.65;
        contrast = 0.95;
      }];
      label = [
        (label // {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +%H'';
          font_family = "Syncopate Bold";
          font_size = 125;
          color = "rgb(${p.foreground})";
          position = "-65, 185";
        })
        (label // {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +%M'';
          font_family = "Syncopate Bold";
          font_size = 125;
          color = "rgb(b8bb26)";
          position = "10, 45";
        })
        (label // {
          text = ''cmd[update:1000] ${pkgs.coreutils}/bin/date +'%d %B, %a.' '';
          font_size = 18;
          position = "10, -65";
        })
        (label // {
          text = "  $USER";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 18;
          position = "0, -215";
        })
        (label // {
          text = "$LAYOUT";
          font_size = 12;
          color = "rgb(${p.border})";
          position = "0, -330";
        })
      ];
      input-field = [{
        monitor = "";
        size = "320, 58";
        position = "0, -280";
        halign = "center";
        valign = "center";
        rounding = -1;
        outline_thickness = 2;
        outer_color = "rgba(${p.border}55)";
        inner_color = "rgba(${p.selection}bb)";
        font_color = "rgb(${p.foreground})";
        font_family = "JetBrainsMono Nerd Font";
        check_color = "rgb(${p.green})";
        fail_color = "rgb(${p.red})";
        capslock_color = "rgb(${p.yellow})";
        dots_size = 0.23;
        dots_spacing = 0.25;
        dots_center = true;
        fade_on_empty = false;
        placeholder_text = "  Пароль";
        fail_text = "Неверный пароль ($ATTEMPTS)";
      }];
    };
  };
}
