
-- Add plugins directory to lua path for modular config
local config_path = vim.fn.stdpath("config")
package.path = package.path .. ";" .. config_path .. "/lua/?.lua"
package.path = package.path .. ";" .. config_path .. "/lua/?/init.lua"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings (migrated from vimrc)
vim.opt.hidden = true -- Allow switching buffers without saving
vim.opt.mouse = "a" -- Enable mouse support in all modes
vim.opt.cursorline = true -- Highlight current line
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.wildmode = "list:longest" -- Command completion behavior
vim.opt.directory = vim.fn.expand("~/.vim/tmp") -- Swap file location
vim.opt.backspace = "indent,eol,start" -- Allow backspace over everything
vim.opt.splitright = true -- New vertical splits open right
vim.opt.splitbelow = true -- New horizontal splits open below
vim.opt.tabstop = 2 -- Tab width in spaces
vim.opt.shiftwidth = 2 -- Indentation width
vim.opt.scrolloff = 8 -- Keep 8 lines visible around cursor
vim.opt.timeout = false -- Disable timeout for key sequences
vim.opt.incsearch = true -- Show matches while typing search
vim.opt.laststatus = 2 -- Always show status line
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.ignorecase = true -- Case-insensitive search by default
vim.opt.smartcase = true -- Case-sensitive if search has uppercase
vim.opt.hlsearch = true -- Highlight all search matches
vim.opt.autoread = true -- Auto-reload files changed outside vim
vim.opt.foldenable = true -- Enable folding
vim.opt.foldmethod = "expr" -- Use indentation for folding
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99 -- Start with all folds open
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

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

-- Fix treesitter highlighting errors when deleting lines
vim.api.nvim_create_autocmd("TextChanged", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local ft = vim.bo[buf].filetype

    -- Skip filetypes that don't have treesitter parsers
    local skip_filetypes = {
      "TelescopePrompt", "NvimTree", "help", "lazy", "mason",
      "copilot-chat", "startify", "qf", "prompt"
    }

    for _, skip_ft in ipairs(skip_filetypes) do
      if ft == skip_ft then return end
    end

    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        local ok, parser = pcall(vim.treesitter.get_parser, buf)
        if ok and parser then
          parser:parse()
        end
      end
    end)
  end,
})

-- Key mappings (migrated from vimrc)
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<C-k>", "<C-w><Up>")
vim.keymap.set("n", "<C-j>", "<C-w><Down>")
vim.keymap.set("n", "<C-l>", "<C-w><Right>")
vim.keymap.set("n", "<C-h>", "<C-w><Left>")
vim.keymap.set("n", "<F2>", ":set invpaste paste?<CR>")

-- Window resizing mappings
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

-- Folding mappings
vim.keymap.set("n", "<Space>", "za")
vim.keymap.set("v", "<Space>", "zf")

-- Strip trailing whitespace function
local function strip_trailing_whitespace()
  local save_pos = vim.fn.getpos(".")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos(".", save_pos)
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = strip_trailing_whitespace,
})

-- Plugin setup - Load all plugins from modular configuration
require("lazy").setup(require("plugins"))
