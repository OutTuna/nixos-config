{ pkgs, ... }:

let
  wallpaper = import ./wallpaper-source.nix { inherit pkgs; };
in
{
  systemd.user.services.gruvbox-wallpaper = {
    Unit = {
      Description = "Gruvbox forest-road wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill -c '#1d2021'";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
