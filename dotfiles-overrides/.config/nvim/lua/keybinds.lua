-- Keybindings Configuration
-- All keybindings in one place. LSP keybinds are setup via autocmd callback.

vim.g.mapleader = "," -- Set leader key

local keymap = vim.keymap.set               -- Shorthand
local builtin = require("telescope.builtin") -- Telescope functions
local silent = { silent = true }             -- Silent option

-- Basic
keymap('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window navigation
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-l>", "<C-w>l")

-- Window resizing
keymap("n", "<C-Up>", ":resize +2<CR>", silent)
keymap("n", "<C-Down>", ":resize -2<CR>", silent)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", silent)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", silent)

-- Folding
keymap("n", "<Space>", "za")
keymap("v", "<Space>", "zf")

-- File tree
keymap("n", "<leader>e", ":Neotree toggle<CR>")

-- Window picker
keymap("n", "<leader>w", function()
  local win = require('window-picker').pick_window() or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)
end)

-- Buffers
keymap("n", "<leader>bn", ":BufferLineCycleNext<CR>")
keymap("n", "<leader>bp", ":BufferLineCyclePrev<CR>")
keymap("n", "<leader>bx", ":bdelete<CR>")
keymap("n", "<leader>bc", ":enew<CR>")
keymap("n", "<leader>bX", ":BufferLineCloseOthers<CR>")
keymap("n", "<leader>bb", ":BufferLinePick<CR>")
keymap("n", "<leader>b<", ":BufferLineMovePrev<CR>")
keymap("n", "<leader>b>", ":BufferLineMoveNext<CR>")

for i = 1, 9 do
  keymap("n", "<leader>b" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>")
end

-- Telescope
keymap("n", "<leader>ff", builtin.find_files)
keymap("n", "<leader>fg", builtin.live_grep)
keymap("n", "<leader>fb", builtin.buffers)
keymap("n", "<leader>fh", builtin.help_tags)
keymap("n", "<leader>fd", builtin.diagnostics)
keymap("n", "<C-g>", builtin.git_status)

-- Git
keymap("n", "]c", function()
  if vim.wo.diff then
    vim.cmd("normal! ]c")
  else
    require("gitsigns").nav_hunk("next")
  end
end)

keymap("n", "[c", function()
  if vim.wo.diff then
    vim.cmd("normal! [c")
  else
    require("gitsigns").nav_hunk("prev")
  end
end)

keymap("n", "<leader>gp", require("gitsigns").preview_hunk)
keymap("n", "<leader>gr", require("gitsigns").reset_hunk)
keymap("n", "<leader>gs", require("gitsigns").stage_hunk)
keymap("n", "<leader>gu", require("gitsigns").undo_stage_hunk)
keymap("n", "<leader>gb", require("gitsigns").blame_line)
keymap("n", "<leader>gg", "<cmd>LazyGit<cr>")

-- Markdown
keymap("n", "<leader>mp", "<cmd>MarkdownPreview<cr>")
keymap("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>")

-- Format & align
keymap("n", "<leader>af", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients > 0 then
    vim.lsp.buf.format({ async = false })
  else
    vim.cmd("normal! gg=G")
  end
  vim.cmd("normal! gg")
  vim.cmd("EasyAlign */--/")
  vim.notify("Document formatted and aligned")
end)

-- F-keys
keymap("n", "<F1>", function()
  local enabled = require("precognition").toggle()
  vim.notify(enabled and "Precognition enabled" or "Precognition disabled")
end)

keymap("n", "<F2>", function()
  vim.cmd("set invpaste")
  vim.notify(vim.o.paste and "Paste mode enabled" or "Paste mode disabled")
end)

keymap("n", "<F3>", function()
  if vim.g.hardtime_enabled == nil then vim.g.hardtime_enabled = false end
  require("hardtime").toggle()
  vim.g.hardtime_enabled = not vim.g.hardtime_enabled
  vim.notify(vim.g.hardtime_enabled and "Hardtime enabled" or "Hardtime disabled")
end)

keymap("n", "<F4>", function()
  require("notify").dismiss({ silent = true, pending = true })
end)

-- LSP (called from autocmd)
local M = {}
function M.setup_lsp(bufnr)
  local opts = { buffer = bufnr, silent = true }
  
  keymap("n", "gd", vim.lsp.buf.definition, opts)
  keymap("n", "gD", vim.lsp.buf.declaration, opts)
  keymap("n", "gi", vim.lsp.buf.implementation, opts)
  keymap("n", "gt", vim.lsp.buf.type_definition, opts)
  keymap("n", "gr", vim.lsp.buf.references, opts)
  keymap("n", "K", vim.lsp.buf.hover, opts)
  keymap("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  keymap({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, opts)
  keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
  keymap({"n", "v"}, "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts)
  keymap("n", "<leader>ld", vim.diagnostic.open_float, opts)
  keymap("n", "[d", vim.diagnostic.goto_prev, opts)
  keymap("n", "]d", vim.diagnostic.goto_next, opts)
  keymap("n", "<leader>lq", vim.diagnostic.setloclist, opts)
  keymap("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, opts)
  keymap("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, opts)
  keymap("n", "<leader>lwl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
end

return M
