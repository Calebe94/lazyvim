-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

-- +file/find
-- ====================

-- Save file
map({ "n", "i" }, "<leader>fs", "<cmd>w<cr><esc>", { desc = "Save File" })

-- +open
-- ====================
require('which-key').add {
  { '<leader>o', group = '+open', icon = '📂' },
}
-- Terminal mappings
map("n", "<leader>oT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ot", function()
  require("toggleterm").toggle()
end, { desc = "Toggle Terminal (Root Dir)" })

-- Open Dashboard
map("n", "<leader>od", "<cmd>Dashboard<cr>", { desc = "Open Dashboard" })

-- Open NeoTree
map("n", "<leader>op", function()
  require("neo-tree.command").execute({ toggle = true, dir = LazyVim.root() })
end, { desc = "Open NeoTree (Root Dir)" })


-- +git
-- ====================

-- Open Neogit interface in the current path
map("n", "<leader>gg", function()
  require("neogit").open({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Open Neogit (Current Path)" })

-- Mapeia <leader>go para executar `oco --yes` na raiz do repositório Git
vim.keymap.set("n", "<leader>go", function()
  -- Usa `git rev-parse --show-toplevel` para obter a raiz do repositório
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

  -- Verifica se estamos em um repositório Git
  if git_root and git_root ~= "" then
    -- Executa o comando `oco --yes` na raiz do repositório
    vim.fn.jobstart({ "oco", "--yes" }, {
      cwd = git_root,
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.notify("Commit generated successfully!", vim.log.levels.INFO)
        else
          vim.notify("Failed to generate commit.", vim.log.levels.ERROR)
        end
      end,
    })
  else
    vim.notify("Not inside a Git repository.", vim.log.levels.ERROR)
  end
end, { desc = "Generate commit" })

-- +project
-- ====================

-- Project management submenu
require('which-key').add {
  { '<leader>p', group = '+project', icon = '📂' },
}

-- Add a project
map("n", "<leader>pa", function()
  require("project_nvim.project").add_project(vim.fn.input("Add project path: "))
end, { desc = "Add New Project" })

-- Delete a project
map("n", "<leader>pd", function()
  local project_path = vim.fn.input("Delete project path: ")
  require("project_nvim.project").remove_project(project_path)
end, { desc = "Delete Project" })

-- Open projects list
map("n", "<leader>pp", "<cmd>Telescope projects<cr>", { desc = "Switch Project" })

-- General Keymaps
-- ====================

-- Exit TERMINAL mode on terminal
map("t", "<ESC>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Enter Normal Mode" })

-- open file_browser with the path of the current buffer
map("n", "<leader>.", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "Find file" })

-- Mapeamento para abrir o Live Grep com o texto sob o cursor
map("n", "<leader>*", function()
  local search_term = vim.fn.expand("<cword>") -- Pega a palavra sob o cursor no modo normal
  require("telescope.builtin").live_grep({ default_text = search_term })
end, { desc = "Live Grep com o termo selecionado" })

-- Para o modo visual, que pega o texto selecionado
map("v", "<leader>*", function()
  local search_term = vim.fn.escape(vim.fn.getreg("v"), "\\") -- Escapa o texto selecionado para pesquisa
  require("telescope.builtin").live_grep({ default_text = search_term })
end, { desc = "Live Grep com o texto selecionado" })

-- +lsp
-- ======================

local opts = { noremap = true, silent = true }

-- Navegação LSP
map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)

-- Diagnósticos
map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
