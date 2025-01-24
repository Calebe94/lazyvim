local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
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
      opts = {
        ensure_installed = {
          -- python
          "ruff-lsp",
          "pyright",
          "mypy",
          "black",
          "isort",
          "flake8",

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
      "neovim/nvim-lspconfig",
      config = function()
        local lspconfig = require("lspconfig")

        -- Configuração para o Pyright (LSP para Python)
        lspconfig.pyright.setup({
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
        })

        -- Configuração para ativar integração similar ao LSP UI
        require("lspconfig.ui.windows").default_options = {
          border = "rounded",
        }
      end,
    },

    -- Instale e configure o null-ls para ferramentas como Black, Ruff, Flake8, Mypy, Isort
    {
      "nvimtools/none-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = function()
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            -- Formatadores
            null_ls.builtins.formatting.black.with({
              extra_args = { "--line-length", "88" }, -- Ajuste a largura da linha conforme necessário
            }),
            null_ls.builtins.formatting.isort,
            null_ls.builtins.formatting.pyink,

            -- Linters
            null_ls.builtins.diagnostics.mypy,
            null_ls.builtins.diagnostics.pydoclint,
            
            null_ls.builtins.diagnostics.pylint.with({
              diagnostics_postprocess = function(diagnostic)
                diagnostic.code = diagnostic.message_id
              end,
            }),
          },

          -- Configuração para rodar ao salvar automaticamente
          on_attach = function(client, bufnr)
            -- Habilita o auto-format ao salvar
            if client.server_capabilities.documentFormattingProvider then
              vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
                vim.lsp.buf.format()
              end, { desc = "Format current buffer" })
            end

            -- Habilita o auto-lint ao salvar
            if client.server_capabilities.documentRangeFormattingProvider then
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("LSPAutoFormat", { clear = true }),
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({ async = true })
                end,
              })
            end
          end,
        })
      end,
    },
    { "nvimdev/dashboard-nvim", event = "VimEnter" },
    { 
      "terrortylor/nvim-comment",
      config = function()
        require('nvim_comment').setup(
          {
            line_mapping = "<leader>cl",
            operator_mapping = "<leader>cc",
            comment_chunk_text_object = "ic"
          }
        )
      end
    },
    {
      "OXY2DEV/markview.nvim",
      lazy = false,      -- Recommended
      -- ft = "markdown" -- If you decide to lazy-load anyway
      dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-tree/nvim-web-devicons"
      }
    },
    -- Configuração para integração com virtualenvs usando pyvenv
    {
      "AckslD/swenv.nvim",
      opts = {
        venv_dirs = { "~/.virtualenvs", "venv" }, -- Ajuste conforme necessário
      },
    },
    {
      "glepnir/lspsaga.nvim",
      event = "BufRead",
      opts = {
        ui = {
          border = "rounded",
        },
      },
    },

    -- import any extras modules here
    -- { import = "lazyvim.plugins.extras.lang.typescript" },
    -- { import = "lazyvim.plugins.extras.lang.json" },
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" },
    -- import/override with your plugins
    { import = "lazyvim.plugins.extras.lsp.none-ls" },
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
