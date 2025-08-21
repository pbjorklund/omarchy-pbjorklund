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
  require("plugins.file-watcher"),
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

vim.opt.clipboard = "unnamedplus"

-- Setup all keybinds
require("keybinds").setup()

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})
