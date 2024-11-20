local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
    lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim",                                 import = "lazyvim.plugins" },
    { 
      "nvim-telescope/telescope.nvim",
      config = function()
        require('telescope').setup({
          extensions = {
            file_browser = {
              hidden = { file_browser = true, folder_browser = true },
              prompt_path = true,
            },
          },
          defaults = {
            file_ignore_patterns = {},
          },
          pickers = {
            find_files = {
              no_ignore = true,
              find_command = {
                "rg",
                "--no-ignore",
                "--hidden",
                "--files",
                "-g",
                "!**/node_modules/*",
                "-g",
                "!**/venv/*",
                "-g",
                "!**/.git/*",
                "-g",
                "!**/.mypy_cache/*",
                "-g",
                "!**/__pycache__/*",
              },
            },
          },
        })
      end
    },
    { import = "lazyvim.plugins.extras.editor.telescope" },
    {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration
        "nvim-telescope/telescope.nvim", -- optional
      },
      config = function()
        require('neogit').setup {}
      end
    },
    {
      "numToStr/Comment.nvim",
      config = function()
        require('Comment').setup()
      end
    }, 
    { "akinsho/toggleterm.nvim" },
    {
      "ahmedkhalf/project.nvim",
      config = function()
        require("project_nvim").setup {
          detection_methods = { "pattern", "lsp" },
          patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pyproject.toml" },
        }
      end,
    },
    { 'echasnovski/mini.nvim',       version = '*' },
    { 'nvim-tree/nvim-web-devicons', version = '*' },
    {
      "williamboman/mason.nvim",
      -- opts will be merged with the parent spec
      opts = {
        ensure_installed = {
          -- python
          "ruff-lsp",
          "pyright",

          -- lua
          "lua-language-server",
          "stylua",

          -- shell
          "shellcheck",
          "shfmt",

          -- docker
          "dockerfile-language-server",

          -- javascript/typescript
          "prettierd",
          "typescript-language-server",
          "eslint-lsp",

          -- rust
          "rustfmt",
          "rust-analyzer",

          -- go
          -- handled by lazy.lua
        },
      },
    },
    {
      "williamboman/mason-lspconfig.nvim",
    },
    {
      "neovim/nvim-lspconfig",
      config = function()
        require("lspconfig").ruff_lsp.setup({})
      end
    },
    -- change null-ls config
    {
      "jose-elias-alvarez/null-ls.nvim",
      dependencies = { "mason.nvim" },
      event = { "BufReadPre", "BufNewFile" },
      opts = function()
        local mason_registry = require("mason-registry")
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics
        local code_actions = null_ls.builtins.code_actions

        null_ls.setup({
          -- debug = true, -- Turn on debug for :NullLsLog
          debug = false,
          -- diagnostics_format = "#{m} #{s}[#{c}]",
          sources = {
            -- list of supported sources:
            -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

            -- get from $PATH
            diagnostics.ruff,
            diagnostics.mypy,
            formatting.black,

            -- get from mason
            formatting.stylua.with({
              command = mason_registry.get_package("stylua").path,
              extra_args = { "--indent-type", "Spaces", "--indent-width", "2" },
            }),
            formatting.shfmt.with({
              command = mason_registry.get_package("shfmt").path,
            }),
            formatting.prettierd.with({
              command = mason_registry.get_package("prettierd").path,
            }),
            formatting.rustfmt.with({
              command = mason_registry.get_package("rustfmt").path,
            }),
            formatting.yamlfix.with({
              command = mason_registry.get_package("yamlfix").path, -- requires python
            }),

            diagnostics.yamllint.with({
              command = mason_registry.get_package("yamllint").path,
            }),

            code_actions.shellcheck.with({
              command = mason_registry.get_package("shellcheck").path,
            }),
          },
        })
      end,
    },
    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
