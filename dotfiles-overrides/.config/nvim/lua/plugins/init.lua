-- Load all plugin configurations
return {
  -- Core functionality
  require("plugins.telescope"),
  require("plugins.lsp"),
  
  -- Movement and habits
  require("plugins.hardtime"),
  require("plugins.precognition"),
  require("plugins.window-picker"),
  
  -- Colorscheme
  {
    "Mofiqul/vscode.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("vscode")
    end,
  },

  -- Git integration
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

  -- Treesitter
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
        fold = {
          enable = true,
        },
      })
    end,
  },

  -- UI plugins
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          numbers = "ordinal",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = true,
          show_close_icon = false,
          separator_style = "slant",
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left"
            }
          }
        }
      })

      -- Buffer navigation
      vim.keymap.set("n", "<leader>bn", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
      vim.keymap.set("n", "<leader>bp", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
      vim.keymap.set("n", "<leader>bx", ":bdelete<CR>", { desc = "Close current buffer" })
      vim.keymap.set("n", "<leader>bc", ":enew<CR>", { desc = "Create new buffer" })
      vim.keymap.set("n", "<leader>bX", ":BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
      vim.keymap.set("n", "<leader>bb", ":BufferLinePick<CR>", { desc = "Pick buffer" })
      vim.keymap.set("n", "<leader>b<", ":BufferLineMovePrev<CR>", { desc = "Move buffer left" })
      vim.keymap.set("n", "<leader>b>", ":BufferLineMoveNext<CR>", { desc = "Move buffer right" })

      -- Direct buffer access (1-9)
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>b" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
      end
    end,
  },

  -- File tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup()
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file tree" })
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

  -- GitHub Copilot
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_no_tab_map = true
      vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        silent = true
      })
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    config = function()
      local wk = require("which-key")
      wk.add({
        { "<leader>f", group = "Find" },
        { "<leader>ff", desc = "Find Files" },
        { "<leader>fg", desc = "Live Grep" },
        { "<leader>fb", desc = "Buffers" },
        { "<leader>fh", desc = "Help Tags" },
        { "<leader>fd", desc = "Diagnostics" },
        { "<leader>e", desc = "Toggle file tree" },
        { "<leader>v", desc = "Edit config" },
        { "<leader>b", group = "Buffer" },
        { "<leader>bn", desc = "Next buffer" },
        { "<leader>bp", desc = "Previous buffer" },
        { "<leader>bx", desc = "Close current buffer" },
        { "<leader>bc", desc = "Create new buffer" },
        { "<leader>bX", desc = "Close other buffers" },
        { "<leader>bb", desc = "Pick buffer" },
        { "<leader>b<", desc = "Move buffer left" },
        { "<leader>b>", desc = "Move buffer right" },
        { "<leader>c", group = "Code" },
        { "<leader>ca", desc = "Code Action" },
        { "<leader>r", group = "LSP" },
        { "<leader>rn", desc = "Rename" },
        { "<leader>g", group = "Git" },
        { "<leader>gg", desc = "LazyGit" },
        { "<leader>gp", desc = "Preview git hunk" },
        { "<leader>gr", desc = "Reset git hunk" },
        { "<leader>w", desc = "Pick a window" },
        { "<leader>m", group = "Markdown" },
        { "<leader>mp", desc = "Markdown Preview Start" },
        { "<leader>ms", desc = "Markdown Preview Stop" },
        { "]c", desc = "Next git change" },
        { "[c", desc = "Previous git change" },
        { "<leader>h", function() wk.show({ global = true }) end, desc = "Show All Keybindings" },
        { "<C-g>", desc = "Git Status" },
        { "<F1>", desc = "Toggle Precognition" },
        { "<F2>", desc = "Toggle Paste Mode" },
        { "<F3>", desc = "Toggle Hardtime" },
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

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
    end,
  },

  -- Markdown Preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_browser = "zen-browser"
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

  -- Notifications
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        background_colour = "#000000",
        fps = 30,
        icons = {
          DEBUG = "",
          ERROR = "",
          INFO = "",
          TRACE = "✎",
          WARN = ""
        },
        level = 2,
        minimum_width = 50,
        render = "default",
        stages = "fade_in_slide_out",
        timeout = 3000,
        top_down = true
      })
      vim.notify = notify
    end,
  },
}