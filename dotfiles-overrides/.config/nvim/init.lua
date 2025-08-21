-- Bootstrap lazy.nvim
require("config.lazy").bootstrap()

-- Plugin setup - Load all plugins from individual files
require("lazy").setup({
  require("plugins.telescope"),          -- Essential for fast file/text searching - replaces fzf/grep workflows
  require("plugins.lsp"),                -- Core language server support - enables IDE-like features for all languages
  require("plugins.hardtime"),           -- Training wheels to learn efficient Vim motions and break bad habits
  require("plugins.precognition"),       -- Visual hints for Vim motions - helps learn movement commands
  require("plugins.window-picker"),      -- Quick window switching in complex layouts - better than Ctrl+w navigation
  require("plugins.colorscheme"),        -- Consistent theming across all projects and environments
  require("plugins.gitsigns"),           -- Essential git integration - see changes inline without external tools
  require("plugins.treesitter"),         -- Better syntax highlighting and text objects - makes code more readable
  require("plugins.bufferline"),         -- Tab-like buffer management - familiar interface for multiple files
  require("plugins.neo-tree"),           -- Project file browser - essential for navigating large codebases
  require("plugins.lualine"),            -- Status line with useful context - shows mode, git branch, LSP status
  require("plugins.copilot"),            -- AI-powered code completion - significantly speeds up development
  require("plugins.which-key"),          -- Command discovery - essential for learning and remembering keybinds
  require("plugins.neoscroll"),          -- Smooth scrolling for better visual tracking when reading code
  require("plugins.lazygit"),            -- Full-featured git TUI - handles complex git operations efficiently
  require("plugins.markdown-preview"),   -- Live markdown preview - essential for documentation work
  require("plugins.nvim-notify"),        -- Better notification system - cleaner than default vim messages
  require("plugins.alignment"),          -- Code formatting alignment - keeps code clean and consistent
  require("plugins.file-watcher"),       -- Auto-reload changed files - prevents conflicts with external editors
  require("plugins.whitespace-cleanup"), -- Automatic trailing whitespace removal - keeps code clean
})

-- Basic settings
-- ===============

-- Editor behavior
vim.opt.timeout = false                         -- Complex key sequences shouldn't timeout mid-input
vim.opt.clipboard = "unnamedplus"               -- Seamless copy/paste between vim and system

-- Display and UI
vim.opt.number = true                           -- Essential for code navigation and debugging
vim.opt.relativenumber = true                   -- Makes movement commands (5j, 3k) more intuitive
vim.opt.signcolumn = "yes"                      -- Prevents jarring text shifts when diagnostics appear
vim.opt.cursorline = true                       -- Easier to track cursor position in large files
vim.opt.scrolloff = 8                           -- Maintains context when scrolling through code

-- Window splits
vim.opt.splitright = true                       -- Reading left-to-right, new content should appear right
vim.opt.splitbelow = true                       -- Natural downward flow for new content

-- Indentation and formatting
vim.opt.expandtab = true                        -- Spaces are more consistent across different editors/systems
vim.opt.tabstop = 2                             -- Compact indentation for better screen real estate
vim.opt.shiftwidth = 2                          -- Consistent with tabstop for uniform indentation

-- Search behavior
vim.opt.ignorecase = true                       -- Most searches don't care about case
vim.opt.smartcase = true                        -- Override ignorecase when intentionally using caps

-- Code folding
vim.opt.foldmethod = "expr"                     -- Treesitter provides smarter folding than indentation
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99                          -- Start with code visible, fold manually as needed

-- Completion and command line
vim.opt.wildmode = "longest:full,full"          -- Complete longest common string, then show all options
vim.opt.completeopt = ""                        -- Copilot handles completion better than built-in

-- File management
vim.opt.swapfile = false                        -- Modern editors auto-save, swap files create clutter

-- Setup all keybinds
require("keybinds").setup()
