{ pkgs, lib, ... }:

let
  p = import ./theme/palette.nix;
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = { terminal = "${pkgs.foot}/bin/foot"; font = "JetBrainsMono Nerd Font:size=12"; prompt = "Apps> "; };
      colors = {
        background = "${p.background}ff";
        text = "${p.foreground}ff";
        match = "${p.green}ff";
        selection = "${p.selection}ff";
        selection-text = "${p.text}ff";
        border = "${p.border}ff";
      };
      border.radius = 0;
    };
  };
  services.mako = {
    enable = true;
    settings = {
      background-color = "#${p.surface}";
      text-color = "#${p.foreground}";
      border-color = "#${p.border}";
      border-radius = 0;
      font = "JetBrainsMono Nerd Font 11";
      default-timeout = 5000;
    };
  };
  services.hyprpolkitagent.enable = true;
  systemd.user.services = (lib.genAttrs
    [ "waybar" "hypridle" "hyprpolkitagent" ]
    (_: { Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=Hyprland"; })) // {
  # The condition-only unit above masks mako's packaged D-Bus unit, so provide
  # a complete service rather than an invalid unit containing only [Unit].
  mako = {
    Unit = {
      Description = "Mako notification daemon";
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  };
}
