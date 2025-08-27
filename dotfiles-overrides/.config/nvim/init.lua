-- pbjorklund Neovim Configuration
-- File structure:
--   init.lua - Main entry point (this file)
--   lua/options.lua - All vim.opt settings
--   lua/keybinds.lua - All keybindings (LSP keybinds are setup via autocmd)
--   lua/plugins/ - Individual plugin configurations
--   lua/config/ - Bootstrap and utility configs

-- Bootstrap lazy.nvim plugin manager
require("config.lazy").bootstrap()

-- Load all plugins from individual files
require("lazy").setup({
  require("plugins.telescope"),          -- File/text search
  require("plugins.lsp"),                -- Language server support
  require("plugins.hardtime"),           -- Learn efficient vim motions
  require("plugins.precognition"),       -- Visual motion hints
  require("plugins.window-picker"),      -- Quick window switching
  require("plugins.colorscheme"),        -- Theme management
  require("plugins.gitsigns"),           -- Git integration
  require("plugins.treesitter"),         -- Syntax highlighting
  require("plugins.bufferline"),         -- Buffer management
  require("plugins.neo-tree"),           -- File browser
  require("plugins.copilot"),            -- AI completion
  require("plugins.which-key"),          -- Keybind discovery
  require("plugins.neoscroll"),          -- Smooth scrolling
  require("plugins.lazygit"),            -- Git TUI
  require("plugins.markdown-preview"),   -- Markdown preview
  require("plugins.nvim-notify"),        -- Notifications
  require("plugins.alignment"),          -- Code alignment
  require("plugins.file-watcher"),       -- Auto-reload files
  require("plugins.whitespace-cleanup"), -- Clean whitespace
  require("plugins.kanata"),             -- Kanata formatting
})

require("options")      -- Load vim options
require("keybinds")     -- Load keybindings
