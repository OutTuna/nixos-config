{ ... }:

{
  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
    -- LazyVim defaults plus the shortcuts already documented in dc.
    vim.keymap.set("n", "<leader>fg", function() Snacks.picker.grep() end, { desc = "Grep" })
    vim.keymap.set("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help Pages" })
    vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save File" })
  '';
}
