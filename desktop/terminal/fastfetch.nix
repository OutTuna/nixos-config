{ config, lib, ... }:
{
  # Keep a reproducible base, but let Noctalia merge logo/display colors into
  # the writable config.jsonc. A store symlink there would break its hook.
  xdg.configFile."fastfetch/base.json".text = builtins.toJSON {
    logo.type = "auto";
    modules = [
      "title" "separator" "os" "host" "kernel" "uptime" "packages"
      "shell" "display" "wm" "terminal" "cpu" "gpu" "memory" "disk"
      "break" "colors"
    ];
  };
  home.activation.seedFastfetchConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -e "${config.xdg.configHome}/fastfetch/config.jsonc" ]; then
      run cp "${config.xdg.configHome}/fastfetch/base.json" "${config.xdg.configHome}/fastfetch/config.jsonc"
      run chmod u+w "${config.xdg.configHome}/fastfetch/config.jsonc"
    fi
  '';
}
