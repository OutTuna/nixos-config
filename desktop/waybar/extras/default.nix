{ pkgs, lib, ... }:
let
  telemetry = pkgs.writeScript "waybar-telemetry" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./telemetry.py}
  '';
  calendar = pkgs.writeShellScript "waybar-calendar" ''
    exec ${pkgs.util-linux}/bin/flock -n "$XDG_RUNTIME_DIR/waybar-calendar.lock" \
      ${pkgs.zenity}/bin/zenity --calendar --title="Календарь" \
      --text="Выберите дату" --ok-label="Закрыть" > /dev/null
  '';
in {
  programs.waybar.settings.mainBar = {
    modules-right = lib.mkForce [
      "hyprland/language" "cpu" "custom/cpu-temp" "custom/gpu"
      "memory" "pulseaudio" "network" "bluetooth" "battery" "tray"
    ];
    "custom/cpu-temp" = {
      exec = "${telemetry} cpu-temp";
      return-type = "json";
      interval = 5;
    };
    "custom/gpu" = {
      exec = "${telemetry} gpu";
      return-type = "json";
      interval = 5;
    };
    bluetooth = {
      format = " {status}";
      format-connected = " {num_connections}";
      format-disabled = " off";
      format-off = " off";
      tooltip-format = "Bluetooth: {status}";
      tooltip-format-connected = "{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}";
      on-click = "${pkgs.blueman}/bin/blueman-manager";
    };
    clock.on-click = "${calendar}";
  };
  programs.waybar.style = lib.mkAfter ''
    #custom-cpu-temp, #custom-gpu { padding: 0 5px; }
    #custom-cpu-temp.critical, #custom-gpu.critical { color: #fb4934; }
    #custom-cpu-temp.unavailable, #custom-gpu.unavailable { color: #a89984; }
  '';
}
