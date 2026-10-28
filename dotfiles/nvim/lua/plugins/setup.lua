return {
  { "ellisonleao/gruvbox.nvim" },
  { "LazyVim/LazyVim", opts = { colorscheme = "gruvbox" } },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local clangd = opts.servers.clangd
      local overrides = {
          cmd = {
            "clangd", "--background-index", "--clang-tidy",
            "--header-insertion=iwyu", "--completion-style=detailed",
            "--function-arg-placeholders=true", "--fallback-style=llvm", "--log=error",
          },
          before_init = function(params)
            params.capabilities.offsetEncoding = nil
          end,
          capabilities = { general = { positionEncodings = { "utf-16" } } },
      }
      opts.servers.clangd = vim.tbl_deep_extend("force", clangd, overrides)
      local drivers = require("config.cpp").query_drivers()
      if drivers ~= "" then
        table.insert(opts.servers.clangd.cmd, "--query-driver=" .. drivers)
      end
      -- These are used only without compile_commands.json; project flags win.
      opts.servers.clangd.init_options = opts.servers.clangd.init_options or {}
      opts.servers.clangd.init_options.fallbackFlags = require("config.cpp").fallback_flags()
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd", "lua-language-server", "stylua", "shfmt",
        "pyright", "ruff", "yaml-language-server",
      },
    },
  },
}
