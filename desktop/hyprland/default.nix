{ pkgs, lib, ... }:

let
  helium = pkgs.callPackage ../helium.nix { };
in
{
  imports = [ ./focus-fix ./displays.nix ./input.nix ./appearance.nix ./hyprlock.nix ./hypridle.nix ];
  # Omarchy v3.0.0 defaults, adapted to current Hyprland and NixOS.
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = false; # UWSM manages the session.
    settings = {
      general = {
        layout = "dwindle";
        allow_tearing = false;
      };
      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global,1,10,default"
          "border,1,5.39,easeOutQuint"
          "windows,1,4.79,easeOutQuint"
          "windowsIn,1,4.1,easeOutQuint,popin 87%"
          "windowsOut,1,1.49,linear,popin 87%"
          "fadeIn,1,1.73,almostLinear"
          "fadeOut,1,1.46,almostLinear"
          "fade,1,3.03,quick"
          "layers,1,3.81,easeOutQuint"
          "workspaces,0,1,default"
        ];
      };
      dwindle = { preserve_split = true; force_split = 2; };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
      };
      bind = [
        "SUPER, Return, exec, ${pkgs.foot}/bin/foot"
        "SUPER, code:53, exec, noctalia msg panel-toggle launcher"
        "SUPER, Space, exec, noctalia msg panel-toggle launcher"
        "SUPER, code:25, killactive,"
        "SUPER, code:55, togglefloating,"
        "SUPER, code:44, layoutmsg, togglesplit"
        "SUPER, code:41, fullscreen, 0"
        "SUPER, code:56, exec, ${lib.getExe helium}"
        "SUPER, code:26, exec, thunar"
        "SUPER, code:28, exec, ${pkgs.telegram-desktop}/bin/Telegram"
        "SUPER CTRL, code:46, exec, ${pkgs.hyprlock}/bin/hyprlock"
        "SUPER SHIFT, Escape, exec, ${pkgs.uwsm}/bin/uwsm stop"
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"
        "SUPER SHIFT, left, swapwindow, l"
        "SUPER SHIFT, right, swapwindow, r"
        "SUPER SHIFT, up, swapwindow, u"
        "SUPER SHIFT, down, swapwindow, d"
        "SUPER, Tab, workspace, e+1"
        "SUPER SHIFT, Tab, workspace, e-1"
        "ALT, Tab, cyclenext,"
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"
        "SUPER, code:20, resizeactive, -100 0"
        "SUPER, code:21, resizeactive, 100 0"
        "SUPER SHIFT, code:20, resizeactive, 0 -100"
        "SUPER SHIFT, code:21, resizeactive, 0 100"
        "SHIFT, F11, fullscreen, 0"
        "ALT, F11, fullscreen, 1"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ] ++ lib.concatMap (i: [
        "SUPER, code:${toString (i + 9)}, workspace, ${toString i}"
        "SUPER SHIFT, code:${toString (i + 9)}, movetoworkspace, ${toString i}"
      ]) (lib.range 1 10);
      bindm = [ "SUPER, mouse:272, movewindow" "SUPER, mouse:273, resizewindow" ];
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];
    };
  };
  xdg.configFile."uwsm/env-hyprland".text = ''
    export XCURSOR_SIZE=24
  '';
}
