{ config, lib, pkgs, ... }:
let
  # Set to false and rebuild to restore Waybar + Mako.
  useNoctalia = true;
  # Qt 6.12's opaque-pointer helper still queries completeness of forward
  # declarations, caching false before moc sees the full QObject definition.
  # Preserve opaque-pointer semantics without that premature query (QS only).
  quickshell = pkgs.noctalia-qs.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      ${pkgs.python3}/bin/python3 - <<'PY'
      from pathlib import Path
      import re
      def opaque(m):
          typ = m.group(1)
          return m.group(0) + (
              "\nnamespace QtPrivate { template<> inline constexpr bool "
              f"PointerIsSuitableForMetaTypeHelper<{typ}> = true; }}\n"
          )
      total = 0
      for header in Path("src").rglob("*.hpp"):
          text, count = re.subn(r"Q_DECLARE_OPAQUE_POINTER\((qs::[\w:]+\*)\);", opaque, header.read_text())
          if count:
              header.write_text(text)
              total += count
      assert total == 6, f"Unexpected opaque pointer declarations: {total}"
      PY
    '';
  });
  package = (pkgs.noctalia-shell.override { noctalia-qs = quickshell; }).overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      ${pkgs.python3}/bin/python3 - <<'PY'
      from pathlib import Path
      import re
      # Qt 6.12 exposes Color as a built-in value type. Avoid shadowing our
      # singleton with it in QML expressions.
      for file in Path('.').rglob('*.qml'):
          text = file.read_text()
          text = re.sub(r'\bColor\.', 'NoctaliaColor.', text)
          file.write_text(text)
      Path('Commons/Color.qml').rename('Commons/NoctaliaColor.qml')
      # All first-run choices are Nix-managed; never show the interactive wizard.
      shell = Path('shell.qml')
      text = shell.read_text()
      needle = 'function showWizardOrChangelog() {'
      assert text.count(needle) == 1
      shell.write_text(text.replace(needle, needle + '\n    return; // Declarative Nix setup.\n'))
      PY
    '';
  });
  settings = pkgs.writeText "noctalia-settings.json" (builtins.toJSON {
    settingsVersion = 59; # Schema of the locked noctalia-shell 4.7.7.
    bar = {
      position = "top";
      density = "compact";
      widgets = {
        left = map (id: { inherit id; }) [ "Launcher" "Workspace" "ActiveWindow" ];
        center = [ { id = "Clock"; } ];
        right = map (id: { inherit id; }) [
          "SystemMonitor" "Tray" "Volume" "Network" "Bluetooth"
          "NotificationHistory" "ControlCenter"
        ];
      };
    };
    general = { telemetryEnabled = false; showChangelogOnStartup = false; };
    ui = { fontDefault = "JetBrainsMono Nerd Font"; fontFixed = "JetBrainsMono Nerd Font"; };
    wallpaper.enabled = false;
    dock.enabled = false;
    idle.enabled = false;
    location = { weatherEnabled = false; autoLocate = false; };
    colorSchemes = { darkMode = true; useWallpaperColors = false; syncGsettings = false; };
    templates.enableUserTheming = false;
    appLauncher.terminalCommand = "${pkgs.foot}/bin/foot -e";
    hooks = { enabled = true; screenLock = "${pkgs.hyprlock}/bin/hyprlock"; };
    plugins.autoUpdate = false;
  });
  start = pkgs.writeShellScript "start-noctalia" ''
    # GUI edits are temporary: Nix settings are restored on each service start.
    install -Dm600 ${settings} "$XDG_RUNTIME_DIR/noctalia/settings.json"
    export NOCTALIA_SETTINGS_FILE="$XDG_RUNTIME_DIR/noctalia/settings.json"
    exec ${package}/bin/noctalia-shell
  '';
in lib.mkIf useNoctalia {
  programs.waybar.enable = lib.mkForce false;
  services.mako.enable = lib.mkForce false;
  home.packages = [ package ];
  systemd.user.services.noctalia = {
    Unit = {
      Description = "Noctalia desktop shell (Nix-managed)";
      Conflicts = [ "waybar-recovery.service" "noctalia-fixed-preview.service" ];
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
      X-Restart-Triggers = [ "${settings}" ];
    };
    Service = { ExecStart = "${start}"; Restart = "on-failure"; RestartSec = 3; };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };
}
