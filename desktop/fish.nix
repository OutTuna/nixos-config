{ lib, ... }:

let
  aliases = {
    c = "clear";
    cls = "clear";
    up = "uptime";
    updd = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    upd = "nh os switch /etc/nixos --hostname nixos";
    dcu = "docker compose up -d --build";
    dca = "docker ps";
    dcd = "docker compose down";
    dcr = "docker rm";
    cfg = "sudo nvim /etc/nixos/configuration.nix";
    ncfg = "sudo nvim /etc/nixos/configuration.nix";
    fcfg = "sudo nvim /etc/nixos/flake.nix";
    dcfg = "sudo nvim /etc/nixos/modules/drivers.nix";
    pcfg = "sudo nvim /etc/nixos/modules/programs.nix";
    ccfg = "sudo nvim /etc/nixos/modules/coding.nix";
    hcfg = "sudo nvim /etc/nixos/desktop/hyprland/default.nix";
    mcfg = "sudo nvim /etc/nixos/desktop/hyprland/displays.nix";
    icfg = "sudo nvim /etc/nixos/desktop/hyprland/input.nix";
    wcfg = "sudo nvim /etc/nixos/desktop/waybar/default.nix";
    tcfg = "sudo nvim /etc/nixos/desktop/terminal/default.nix";
    scfg = "sudo nvim /etc/nixos/desktop/fish.nix";
    bcfg = "sudo nvim /etc/nixos/desktop/browser.nix";
  };
  groups = [
    { title = "Terminal"; names = [ "c" "cls" "up" "fetch" ]; }
    { title = "Rebuild System (both use flakes; neither updates flake.lock)"; names = [ "upd" "updd" ]; }
    { title = "Docker (run Compose commands from your project directory)"; names = [ "dcu" "dcd" "dca" "dcr" ]; }
    { title = "System Configs (Neovim only)"; names = [ "ncfg" "ccfg" "pcfg" "dcfg" "fcfg" ]; }
  ];
  help = lib.concatMapStrings (group: ''
    set_color --bold blue
    printf '\n%s\n' ${lib.escapeShellArg group.title}
    set_color normal
    ${lib.concatMapStrings (name: ''
      printf '  %-8s %s\n' ${lib.escapeShellArg name} ${lib.escapeShellArg (aliases.${name} or name)}
    '') group.names}
  '') groups;
in
{
  programs.fish = {
    enable = true;
    shellAliases = aliases;
    interactiveShellInit = ''
      set -g fish_greeting
      if test "$TERM" = foot; and not set -q SSH_CONNECTION
        fetch
      end
    '';
    functions.dc = {
      description = "Show terminal, system, Docker, config, and desktop shortcuts";
      body = help + ''
        set_color --bold blue
        printf '\n%s\n' 'Desktop (Win = Super)'
        set_color normal
        printf '  %-18s %s\n' \
          'Win+X / Win+Space' 'Search installed graphical apps' \
          'Win+Enter' 'Open foot terminal with fish' \
          'Win+B' 'Open Helium browser' \
          'Win+E' 'Open file manager' \
          'Alt+Shift' 'Switch English/Russian' \
          'Win+W' 'Close active window' \
          'Win+F' 'Toggle fullscreen' \
          'Win+V' 'Toggle floating window' \
          'Win+Arrows' 'Focus another window' \
          'Win+1..0' 'Switch workspace' \
          'Win+Shift+1..0' 'Move window to workspace' \
          'Win+Ctrl+L' 'Lock screen' \
          'Win+Shift+Esc' 'Log out' \
          'Print Screen' 'Select screenshot area and copy'
        set_color --bold blue
        printf '\n%s\n' 'Coding / Neovim'
        set_color normal
        printf '  %-18s %s\n' \
          'opencode' 'Start OpenCode in the current project' \
          'nvim <file>' 'Edit a file (i: insert, Esc: normal mode)' \
          ':w / :q / :wq' 'Save / quit / save and quit' \
          ':q!' 'Quit without saving' \
          'Space ff' 'Find project files' \
          'Space fg' 'Search text in project' \
          'Space fb' 'Find open buffers' \
          'Space fh' 'Search Neovim help' \
          'Space w' 'Save file' \
          'Space e' 'File explorer' \
          'Space ca' 'Code actions' \
          'Space cf' 'Format file' \
          ':Lazy / Space l' 'Inspect plugins; update them through Nix, not :Lazy update'
        printf '\n%s\n' \
          'After config edits: save, quit, then run upd or updd.' \
          'upd uses nh; updd uses nixos-rebuild. Both rebuild the locked flake.' \
          'To update pinned versions: sudo nix flake update --flake /etc/nixos, then upd.' \
          'dcr requires a container name or ID; it does not force-remove running containers.' \
          'Docker is socket-activated; the first docker command starts it.' \
          'Type dc to show this help again.'
      '';
    };
  };
}
