{ pkgs, ... }:

{
  programs.neovim.extraPackages = with pkgs; [
    git ripgrep fd fzf lazygit wl-clipboard
    lua-language-server stylua shfmt
    clang-tools pyright ruff yaml-language-server
    gcc tree-sitter
  ];
  xdg.configFile."nvim/lazyvim.json".text = builtins.toJSON {
    extras = [
      "lazyvim.plugins.extras.lang.clangd"
      "lazyvim.plugins.extras.lang.git"
      "lazyvim.plugins.extras.lang.python"
      "lazyvim.plugins.extras.lang.yaml"
    ];
    install_version = 8;
    version = 8;
    news."NEWS.md" = "11866";
  };
  xdg.configFile."nvim/lua/plugins/languages.lua".text = ''
    return {
      -- Nix provides executables instead of Mason's non-Nix downloads.
      { "mason-org/mason.nvim", enabled = false },
      { "mason-org/mason-lspconfig.nvim", enabled = false },
      {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
          local servers = {
          ["*"] = { mason = false },
          lua_ls = { mason = false },
          clangd = {
            mason = false,
            before_init = function(params)
              -- nvim-lspconfig also supplies this deprecated extension.
              params.capabilities.offsetEncoding = nil
            end,
            cmd = {
              "clangd",
              "--log=error",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders=true",
              "--fallback-style=llvm",
            },
            capabilities = {
              general = { positionEncodings = { "utf-16" } },
            },
          },
          pyright = { mason = false },
          ruff = { mason = false },
          yamlls = { mason = false },
          }
          opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, servers)
          -- Remove the legacy extension inherited from LazyVim's clangd extra.
          opts.servers.clangd.capabilities.offsetEncoding = nil
        end,
      },
      { "saghen/blink.cmp", opts = { fuzzy = { implementation = "prefer_rust" } } },
    }
  '';
}
