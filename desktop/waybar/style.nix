{ ... }:

let p = import ../theme/palette.nix;
in
{
  # Frost-Phoenix's colors/layout adapted to our modules, font, and 30px bar.
  programs.waybar.style = ''
    * {
      border: none;
      border-radius: 0;
      padding: 0;
      margin: 0;
      min-height: 0;
      font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono";
      font-weight: bold;
      font-size: 12px;
    }
    window#waybar {
      background: #${p.surface};
      color: #${p.foreground};
      border-top: 1px solid #${p.border};
    }
    tooltip, #tray menu {
      background: #${p.surface};
      border: 1px solid #${p.border};
      color: #${p.foreground};
    }
    tooltip label { margin: 5px; color: #${p.foreground}; }
    #tray menu { padding: 8px; }
    #tray menuitem { padding: 1px; }
    #workspaces { padding-left: 5px; }
    #workspaces button { color: #${p.yellow}; padding: 0 5px; margin-right: 5px; }
    #workspaces button.empty { color: #${p.foreground}; }
    #workspaces button.active { color: #${p.brightOrange}; }
    #workspaces button.urgent, #battery.critical { color: #${p.red}; }
    #clock { color: #${p.foreground}; }
    #custom-apps { font-size: 20px; color: #${p.foreground}; padding: 0 12px; }
    #pulseaudio, #network, #cpu, #memory, #battery, #language { padding: 0 5px; }
    #tray { margin-left: 10px; padding-right: 12px; }
  '';
}
