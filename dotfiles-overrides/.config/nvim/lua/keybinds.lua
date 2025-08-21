-- Set leader key first
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local M = {}

-- Basic mappings
function M.setup_basic()
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
  vim.keymap.set("i", "jj", "<Esc>")
  
  -- Window navigation
  vim.keymap.set("n", "<C-k>", "<C-w><Up>")
  vim.keymap.set("n", "<C-j>", "<C-w><Down>")
  vim.keymap.set("n", "<C-l>", "<C-w><Right>")
  vim.keymap.set("n", "<C-h>", "<C-w><Left>")
  
  -- Window resizing
  vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true })
  vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true })
  vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
  vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })
  
  -- Folding
  vim.keymap.set("n", "<Space>", "za")
  vim.keymap.set("v", "<Space>", "zf")
end

-- Window picker
function M.setup_window_picker()
  vim.keymap.set("n", "<leader>w", function()
    local picked_window_id = require('window-picker').pick_window() or vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(picked_window_id)
  end, { desc = "Pick window" })
end

-- File tree
function M.setup_file_tree()
  vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file tree" })
end

-- Buffer management (BufferLine)
function M.setup_buffers()
  vim.keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
  vim.keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
  vim.keymap.set("n", "<leader>bx", ":bdelete<CR>", { desc = "Close current buffer" })
  vim.keymap.set("n", "<leader>bc", ":enew<CR>", { desc = "Create new buffer" })
  vim.keymap.set("n", "<leader>bX", ":BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
  vim.keymap.set("n", "<leader>bb", ":BufferLinePick<CR>", { desc = "Pick buffer" })
  vim.keymap.set("n", "<leader>b<", ":BufferLineMovePrev<CR>", { desc = "Move buffer left" })
  vim.keymap.set("n", "<leader>b>", ":BufferLineMoveNext<CR>", { desc = "Move buffer right" })
  
  -- Buffer number shortcuts (1-9)
  for i = 1, 9 do
    vim.keymap.set("n", "<leader>b" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
  end
end

-- Telescope (fuzzy finder)
function M.setup_telescope()
  vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
  vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
  vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })
  vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "Diagnostics" })
  vim.keymap.set("n", "<C-g>", require("telescope.builtin").git_status, { desc = "Git status" })
end

-- LSP mappings (to be called from LspAttach autocmd)
function M.setup_lsp(bufnr)
  local opts = { buffer = bufnr, silent = true }
  
  -- Navigation
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
  vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))
  vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "Show references" }))
  
  -- Documentation and hover
  vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
  vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))
  
  -- Code actions and refactoring
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "Code action" }))
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
  
  -- Formatting
  vim.keymap.set("n", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "Format document" }))
  vim.keymap.set("v", "<leader>lf", function()
    vim.lsp.buf.format({ async = true })
  end, vim.tbl_extend("force", opts, { desc = "Format selection" }))
  
  -- Diagnostics
  vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
  vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostics to loclist" }))
  
  -- Workspace
  vim.keymap.set("n", "<leader>lwa", vim.lsp.buf.add_workspace_folder, vim.tbl_extend("force", opts, { desc = "Add workspace folder" }))
  vim.keymap.set("n", "<leader>lwr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", opts, { desc = "Remove workspace folder" }))
  vim.keymap.set("n", "<leader>lwl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, vim.tbl_extend("force", opts, { desc = "List workspace folders" }))
end

-- Git navigation
function M.setup_git()
  vim.keymap.set("n", "]c", function()
    if vim.wo.diff then
      vim.cmd("normal! ]c")
    else
      require("gitsigns").nav_hunk("next")
    end
  end, { desc = "Next git change" })
  
  vim.keymap.set("n", "[c", function()
    if vim.wo.diff then
      vim.cmd("normal! [c")
    else
      require("gitsigns").nav_hunk("prev")
    end
  end, { desc = "Previous git change" })
  
  vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk, { desc = "Preview git hunk" })
  vim.keymap.set("n", "<leader>gr", require("gitsigns").reset_hunk, { desc = "Reset git hunk" })
  vim.keymap.set("n", "<leader>gs", require("gitsigns").stage_hunk, { desc = "Stage git hunk" })
  vim.keymap.set("n", "<leader>gu", require("gitsigns").undo_stage_hunk, { desc = "Undo stage hunk" })
  vim.keymap.set("n", "<leader>gb", require("gitsigns").blame_line, { desc = "Git blame line" })
  vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
end

-- Markdown
function M.setup_markdown()
  vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown Preview Start" })
  vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", { desc = "Markdown Preview Stop" })
end

-- Document formatting and alignment
function M.setup_formatting()
  vim.keymap.set("n", "<leader>af", function()
    -- First format with LSP if available
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    if #clients > 0 then
      vim.lsp.buf.format({ async = false })
    else
      -- Fallback to auto-indent
      vim.cmd("normal! gg=G")
    end
    
    -- Then align comments
    vim.cmd("normal! gg")
    vim.cmd("EasyAlign */--/")
    vim.notify("Document formatted and aligned")
  end, { desc = "Format document and align comments" })
end

-- F-key mappings
function M.setup_fkeys()
  vim.keymap.set("n", "<F1>", function()
    if require("precognition").toggle() then
      vim.notify("Precognition enabled")
    else
      vim.notify("Precognition disabled")
    end
  end, { desc = "Toggle Precognition" })
  
  vim.keymap.set("n", "<F2>", function()
    vim.cmd("set invpaste")
    if vim.o.paste then
      vim.notify("Paste mode enabled")
    else
      vim.notify("Paste mode disabled")
    end
  end, { desc = "Toggle Paste Mode" })
  
  vim.keymap.set("n", "<F3>", function()
    -- Track hardtime state manually since plugin doesn't expose it
    if vim.g.hardtime_enabled == nil then
      vim.g.hardtime_enabled = false -- Default state is now disabled
    end
    
    require("hardtime").toggle()
    vim.g.hardtime_enabled = not vim.g.hardtime_enabled
    
    if vim.g.hardtime_enabled then
      vim.notify("Hardtime enabled")
    else
      vim.notify("Hardtime disabled")
    end
  end, { desc = "Toggle Hardtime" })
  
  vim.keymap.set("n", "<F4>", function()
    require("notify").dismiss({ silent = true, pending = true })
  end, { desc = "Clear all notifications" })
end

-- Setup all keybinds
function M.setup()
  M.setup_basic()
  M.setup_window_picker()
  M.setup_file_tree()
  M.setup_buffers()
  M.setup_telescope()
  M.setup_git()
  M.setup_markdown()
  M.setup_formatting()
  M.setup_fkeys()
end

return M