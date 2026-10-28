{ lib, pkgs, ... }:

let
  v = pkgs.vimPlugins;
  # Names match lazy.nvim's upstream names. No runtime Git clones.
  plugins = {
    "lazy.nvim" = v.lazy-nvim;
    LazyVim = v.LazyVim;
    "gruvbox.nvim" = v.gruvbox-nvim;
    "tokyonight.nvim" = v.tokyonight-nvim;
    catppuccin = v.catppuccin-nvim;
    "snacks.nvim" = v.snacks-nvim;
    "blink.cmp" = v.blink-cmp;
    "friendly-snippets" = v.friendly-snippets;
    "mini.pairs" = v.mini-pairs;
    "mini.ai" = v.mini-ai;
    "mini.icons" = v.mini-icons;
    "ts-comments.nvim" = v.ts-comments-nvim;
    "lazydev.nvim" = v.lazydev-nvim;
    "grug-far.nvim" = v.grug-far-nvim;
    "flash.nvim" = v.flash-nvim;
    "which-key.nvim" = v.which-key-nvim;
    "gitsigns.nvim" = v.gitsigns-nvim;
    "trouble.nvim" = v.trouble-nvim;
    "todo-comments.nvim" = v.todo-comments-nvim;
    "nvim-lspconfig" = v.nvim-lspconfig;
    "conform.nvim" = v.conform-nvim;
    "nvim-lint" = v.nvim-lint;
    "nvim-treesitter" = v.nvim-treesitter;
    "nvim-treesitter-textobjects" = v.nvim-treesitter-textobjects;
    "nvim-ts-autotag" = v.nvim-ts-autotag;
    "bufferline.nvim" = v.bufferline-nvim;
    "lualine.nvim" = v.lualine-nvim;
    "noice.nvim" = v.noice-nvim;
    "nui.nvim" = v.nui-nvim;
    "persistence.nvim" = v.persistence-nvim;
    "plenary.nvim" = v.plenary-nvim;
    "SchemaStore.nvim" = v.SchemaStore-nvim;
    "clangd_extensions.nvim" = v.clangd_extensions-nvim;
    "venv-selector.nvim" = v.venv-selector-nvim;
  };
  treesitter = v.nvim-treesitter.withPlugins (p: with p; [
    bash c cpp diff html javascript jsdoc json lua luadoc luap
    markdown markdown_inline printf python query regex toml tsx typescript
    vim vimdoc xml yaml ninja rst git_config gitcommit git_rebase gitignore gitattributes
  ]);
  paths = lib.mapAttrs (_: p: toString p) plugins;
  parserBundle = pkgs.symlinkJoin {
    name = "lazyvim-treesitter-parsers";
    paths = treesitter.dependencies;
  };
in
{
  # Only precompiled grammars/queries are start plugins; LazyVim loads the rest.
  programs.neovim.plugins = treesitter.dependencies;
  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    -- Make Nix grammars available before any lazy-loaded Treesitter setup.
    vim.opt.rtp:prepend("${parserBundle}")
    vim.opt.rtp:prepend("${v.lazy-nvim}")
    local paths = vim.json.decode([==[${builtins.toJSON paths}]==])
    require("lazy").setup({
      spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "plugins" },
      },
      dev = {
        path = function(plugin)
          -- lazy.nvim also resolves optional extras before filtering them out.
          return paths[plugin.name] or (vim.fn.stdpath("data") .. "/nix-unavailable/" .. plugin.name)
        end,
        patterns = { "" },
        fallback = false,
      },
      defaults = { lazy = false, version = false },
      local_spec = false,
      pkg = { enabled = false },
      rocks = { enabled = false },
      install = { missing = false, colorscheme = { "gruvbox", "habamax" } },
      checker = { enabled = false },
      change_detection = { enabled = false, notify = false },
      performance = { rtp = { reset = false } },
      lockfile = vim.fn.stdpath("state") .. "/lazy/lazy-lock.json",
    })
  '';
  xdg.configFile."nvim/lua/plugins/colorscheme.lua".text = ''
    return {
      { "ellisonleao/gruvbox.nvim" },
      { "LazyVim/LazyVim", opts = { colorscheme = "gruvbox" } },
    }
  '';
  xdg.configFile."nvim/lua/plugins/treesitter.lua".text = ''
    return {
      {
        "nvim-treesitter/nvim-treesitter",
        build = false,
        opts = function(_, opts)
          -- Grammars come from Nix, not :TSInstall/:TSUpdate.
          opts.ensure_installed = {}
          opts.install_dir = "${parserBundle}"
        end,
      },
    }
  '';
}
