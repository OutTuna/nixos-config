{ pkgs, lib, ... }:
let
  switcher = pkgs.writeScript "hypr-alt-tab" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./alt-tab.py}
  '';
in {
  wayland.windowManager.hyprland.settings = {
    misc.focus_on_activate = lib.mkForce false;
    cursor.no_warps = true;
    input.follow_mouse = lib.mkForce 0;
  };
  # Applied after generated settings, so the original binding is removed first.
  wayland.windowManager.hyprland.extraConfig = ''
    unbind = ALT, Tab
    bind = ALT, Tab, exec, ${switcher} next
    bind = ALT SHIFT, Tab, exec, ${switcher} prev
    bindrint = , Alt_L, exec, ${switcher} reset
    bindrint = , Alt_R, exec, ${switcher} reset
  '';
}
