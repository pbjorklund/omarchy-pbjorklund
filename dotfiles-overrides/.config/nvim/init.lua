-- Add plugins directory to lua path for modular config
local config_path = vim.fn.stdpath("config")
package.path = package.path .. ";" .. config_path .. "/lua/?.lua"
package.path = package.path .. ";" .. config_path .. "/lua/?/init.lua"
--

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup - Load all plugins from individual files
require("lazy").setup({
  require("plugins.telescope"),
  require("plugins.lsp"),
  require("plugins.hardtime"),
  require("plugins.precognition"),
  require("plugins.window-picker"),
  require("plugins.colorscheme"),
  require("plugins.gitsigns"),
  require("plugins.treesitter"),
  require("plugins.bufferline"),
  require("plugins.neo-tree"),
  require("plugins.lualine"),
  require("plugins.copilot"),
  require("plugins.which-key"),
  require("plugins.neoscroll"),
  require("plugins.lazygit"),
  require("plugins.markdown-preview"),
  require("plugins.nvim-notify"),
  require("plugins.alignment"),
})

-- Basic settings
vim.opt.hidden = true                           -- Allow switching buffers without saving
vim.opt.mouse = "a"                             -- Enable mouse support in all modes
vim.opt.cursorline = true                       -- Highlight current line
vim.opt.expandtab = true                        -- Convert tabs to spaces
vim.opt.wildmode = "list:longest"               -- Command completion behavior
vim.opt.directory = vim.fn.expand("~/.vim/tmp") -- Swap file location
vim.opt.backspace = "indent,eol,start"          -- Allow backspace over everything
vim.opt.splitright = true                       -- New vertical splits open right
vim.opt.splitbelow = true                       -- New horizontal splits open below
vim.opt.tabstop = 2                             -- Tab width in spaces
vim.opt.shiftwidth = 2                          -- Indentation width
vim.opt.scrolloff = 8                           -- Keep 8 lines visible around cursor
vim.opt.timeout = false                         -- Disable timeout for key sequences
vim.opt.incsearch = true                        -- Show matches while typing search
vim.opt.laststatus = 2                          -- Always show status line
vim.opt.number = true                           -- Show line numbers
vim.opt.relativenumber = true                   -- Show relative line numbers
vim.opt.ignorecase = true                       -- Case-insensitive search by default
vim.opt.smartcase = true                        -- Case-sensitive if search has uppercase
vim.opt.hlsearch = true                         -- Highlight all search matches
vim.opt.autoread = true                         -- Auto-reload files changed outside vim
vim.opt.foldenable = true                       -- Enable folding
vim.opt.foldmethod = "expr"                     -- Use indentation for folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99                          -- Start with all folds open
vim.opt.completeopt = ""                        -- Disable built-in completion since we use Copilot

-- More aggressive file watching
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Force check every second using CursorHold trigger
vim.opt.updatetime = 1000

-- Additional timer for background checking
local function check_file_changes()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
      vim.api.nvim_buf_call(buf, function()
        if vim.fn.mode() ~= "c" then
          vim.cmd("silent! checktime")
        end
      end)
    end
  end
end

local timer = vim.loop.new_timer()
if timer then
  timer:start(2000, 2000, vim.schedule_wrap(check_file_changes))
end

-- Notify when file changed on disk for modified buffers
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})

-- Warn when file changed on disk for modified buffers
vim.api.nvim_create_autocmd("FileChangedShell", {
  pattern = "*",
  callback = function()
    if vim.bo.modified then
      vim.notify("Warning: File has been changed on disk and buffer is modified!", vim.log.levels.WARN)
    end
  end,
})

-- Set leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.opt.clipboard = "unnamedplus"

-- KEY MAPPINGS
-- ========================

-- Basic mappings (migrated from vimrc)
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

-- Window picker
vim.keymap.set("n", "<leader>w", function()
  local picked_window_id = require('window-picker').pick_window() or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(picked_window_id)
end, { desc = "Pick window" })

-- Folding
vim.keymap.set("n", "<Space>", "za")
vim.keymap.set("v", "<Space>", "zf")

-- File tree
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file tree" })

-- Buffer management (BufferLine)
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

-- Telescope (fuzzy finder)
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<C-g>", require("telescope.builtin").git_status, { desc = "Git status" })

-- LSP mappings
local opts = { buffer = true }
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

-- Git navigation
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
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

-- Copilot uses default Tab key for accepting suggestions

-- Markdown
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown Preview Start" })
vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", { desc = "Markdown Preview Stop" })

-- Document formatting and alignment
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

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- F-keys
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
    vim.g.hardtime_enabled = true -- Default state after setup
  end

  require("hardtime").toggle()
  vim.g.hardtime_enabled = not vim.g.hardtime_enabled

  if vim.g.hardtime_enabled then
    vim.notify("Hardtime enabled")
  else
    vim.notify("Hardtime disabled")
  end
end, { desc = "Toggle Hardtime" })
