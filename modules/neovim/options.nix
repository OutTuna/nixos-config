{ ... }:

{
  # Keep upstream defaults, like the original dotfiles.
  xdg.configFile."nvim/lua/config/options.lua".text = ''
    vim.g.lazyvim_picker = "snacks"
    vim.g.lazyvim_cmp = "blink.cmp"
  '';
  xdg.configFile."nvim/lua/config/autocmds.lua".text = ''
    -- LazyVim's default autocommands.
  '';
}
