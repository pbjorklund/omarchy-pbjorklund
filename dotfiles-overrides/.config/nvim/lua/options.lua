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