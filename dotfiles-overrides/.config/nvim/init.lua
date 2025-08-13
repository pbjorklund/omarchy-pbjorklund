-- Bootstrap lazy.nvim
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
vim.opt.hidden = true
vim.opt.mouse = "a"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.wildmode = "list:longest"
vim.opt.directory = vim.fn.expand("~/.vim/tmp")
vim.opt.backspace = "indent,eol,start"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.scrolloff = 8
vim.opt.timeout = false
vim.opt.incsearch = true
vim.opt.foldmethod = "manual"
vim.opt.foldnestmax = 10
vim.opt.foldlevel = 1
vim.opt.foldlevelstart = 99
vim.opt.laststatus = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.autoread = true

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

-- Configure clipboard to use wl-copy (Wayland)
vim.opt.clipboard = "unnamedplus"
vim.g.clipboard = {
  name = "wl-clipboard",
  copy = {
    ["+"] = "wl-copy",
    ["*"] = "wl-copy",
  },
  paste = {
    ["+"] = "wl-paste --no-newline",
    ["*"] = "wl-paste --no-newline",
  },
  cache_enabled = 0,
}

-- Key mappings (migrated from vimrc)
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("n", "<C-k>", "<C-w><Up>")
vim.keymap.set("n", "<C-j>", "<C-w><Down>")
vim.keymap.set("n", "<C-l>", "<C-w><Right>")
vim.keymap.set("n", "<C-h>", "<C-w><Left>")
vim.keymap.set("n", "<leader>v", ":e $MYVIMRC<CR>", { desc = "Edit config" })
vim.keymap.set("n", "<F1>", ":lopen<CR>")
vim.keymap.set("n", "<F2>", ":set invpaste paste?<CR>")

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

-- Crontab fix
vim.api.nvim_create_autocmd("FileType", {
  pattern = "crontab",
  callback = function()
    vim.opt_local.backup = false
    vim.opt_local.writebackup = false
  end,
})

-- Plugin setup
require("lazy").setup({
  -- Colorscheme (VS Code Dark theme)
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- Telescope (replaces bufexplorer)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key"
            }
          }
        },
        pickers = {
          find_files = {
            hidden = true
          }
        }
      })
      -- Key mappings for telescope
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
      vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, {})
      vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, {})
      vim.keymap.set("n", "<leader>fd", require("telescope.builtin").diagnostics, {})
      vim.keymap.set("n", "<C-g>", require("telescope.builtin").git_status, {})
    end,
  },


  -- Git changes explorer
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
      })

      -- Git navigation keymaps
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
    end,
  },


  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- Mason setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "pyright" },
      })

      -- LSP configuration
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Lua LSP
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- TypeScript LSP
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
      })

      -- Python LSP
      lspconfig.pyright.setup({
        capabilities = capabilities,
      })

      -- LSP key mappings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        end,
      })

      -- Completion setup
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "python", "json", "yaml", "html", "css" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "vscode",
        },
      })
    end,
  },

  -- GitHub Copilot with Chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require("CopilotChat").setup({
        debug = false,
      })

      -- Key mappings
      vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { desc = "Open Copilot Chat" })
      vim.keymap.set("v", "<leader>cc", ":CopilotChatVisual<CR>", { desc = "Copilot Chat with selection" })
      vim.keymap.set("n", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Explain code" })
      vim.keymap.set("n", "<leader>cf", ":CopilotChatFix<CR>", { desc = "Fix code" })
      vim.keymap.set("n", "<leader>co", ":CopilotChatOptimize<CR>", { desc = "Optimize code" })
      vim.keymap.set("n", "<leader>ct", ":CopilotChatTests<CR>", { desc = "Generate tests" })
    end,
  },

  -- Which-key for keybinding help
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    config = function()
      local wk = require("which-key")

      -- Add keybinding descriptions
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>ff", desc = "Find Files" },
        { "<leader>fg", desc = "Live Grep" },
        { "<leader>fb", desc = "Buffers" },
        { "<leader>fh", desc = "Help Tags" },
        { "<leader>fd", desc = "Diagnostics" },
        { "<leader>e", desc = "Toggle File Tree" },
        { "<leader>v", desc = "Edit config" },
        { "<leader>c", group = "Code/Copilot" },
        { "<leader>ca", desc = "Code Action" },
        { "<leader>cc", desc = "Copilot Chat" },
        { "<leader>ce", desc = "Explain code" },
        { "<leader>cf", desc = "Fix code" },
        { "<leader>co", desc = "Optimize code" },
        { "<leader>ct", desc = "Generate tests" },
        { "<leader>r", group = "LSP" },
        { "<leader>rn", desc = "Rename" },
        { "<leader>g", group = "Git" },
        { "<leader>gg", desc = "LazyGit" },
        { "<leader>gp", desc = "Preview git hunk" },
        { "<leader>gr", desc = "Reset git hunk" },
        { "<leader>m", group = "Markdown" },
        { "<leader>mp", desc = "Markdown Preview Start" },
        { "<leader>ms", desc = "Markdown Preview Stop" },
        { "]c", desc = "Next git change" },
        { "[c", desc = "Previous git change" },
        { "<leader>h", function() wk.show({ global = true }) end, desc = "Show All Keybindings" },
        { "<C-g>", desc = "Git Status" },
        { "<F1>", desc = "Location List" },
        { "<F2>", desc = "Toggle Paste Mode" },
        { "<Space>", desc = "Toggle Fold" },
        { "K", desc = "Hover Documentation" },
        { "gd", desc = "Go to Definition" },
        { "gr", desc = "References" },
      })
    end,
  },

  -- Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = nil,
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
      })
    end,
  },

  -- LazyGit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
    end,
  },

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && yarn install",
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_browserfunc = ""
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {}
      }
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_highlight_css = ""
      vim.g.mkdp_port = ""
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_theme = "dark"
      
      -- Key mappings
      vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown Preview Start" })
      vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", { desc = "Markdown Preview Stop" })
    end,
  },
})
