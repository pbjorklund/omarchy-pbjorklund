-- Which-key for keybinding help
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
  },
  config = function()
    local wk = require("which-key")
    wk.add({
      -- Alignment
      { "<leader>a", group = "Align" },
      { "<leader>af", desc = "Format document and align comments" },
      
      -- Find/Search
      { "<leader>f", group = "Find" },
      { "<leader>ff", desc = "Find Files" },
      { "<leader>fg", desc = "Live Grep" },
      { "<leader>fb", desc = "Buffers" },
      { "<leader>fh", desc = "Help Tags" },
      { "<leader>fd", desc = "Diagnostics" },
      
      -- File tree
      { "<leader>e", desc = "Toggle file tree" },
      
      -- Buffers
      { "<leader>b", group = "Buffer" },
      { "<leader>bn", desc = "Next buffer" },
      { "<leader>bp", desc = "Previous buffer" },
      { "<leader>bx", desc = "Close current buffer" },
      { "<leader>bc", desc = "Create new buffer" },
      { "<leader>bX", desc = "Close other buffers" },
      { "<leader>bb", desc = "Pick buffer" },
      { "<leader>b<", desc = "Move buffer left" },
      { "<leader>b>", desc = "Move buffer right" },
      
      -- Code Actions
      { "<leader>c", group = "Code" },
      { "<leader>ca", desc = "Code Action" },
      
      -- LSP
      { "<leader>l", group = "LSP" },
      { "<leader>lf", desc = "Format document" },
      { "<leader>ld", desc = "Show line diagnostics" },
      { "<leader>lq", desc = "Diagnostics to loclist" },
      { "<leader>lw", group = "Workspace" },
      { "<leader>lwa", desc = "Add workspace folder" },
      { "<leader>lwr", desc = "Remove workspace folder" },
      { "<leader>lwl", desc = "List workspace folders" },
      
      -- Rename (kept under r for backwards compatibility)
      { "<leader>r", group = "Refactor" },
      { "<leader>rn", desc = "Rename symbol" },
      
      -- Git
      { "<leader>g", group = "Git" },
      { "<leader>gg", desc = "LazyGit" },
      { "<leader>gp", desc = "Preview git hunk" },
      { "<leader>gr", desc = "Reset git hunk" },
      { "<leader>gs", desc = "Stage git hunk" },
      { "<leader>gu", desc = "Undo stage hunk" },
      { "<leader>gb", desc = "Git blame line" },
      
      -- Window management
      { "<leader>w", desc = "Pick a window" },
      
      -- Markdown
      { "<leader>m", group = "Markdown" },
      { "<leader>mp", desc = "Markdown Preview Start" },
      { "<leader>ms", desc = "Markdown Preview Stop" },
      
      -- Git navigation
      { "]c", desc = "Next git change" },
      { "[c", desc = "Previous git change" },
      
      -- Diagnostics navigation
      { "]d", desc = "Next diagnostic" },
      { "[d", desc = "Previous diagnostic" },
      
      -- Help
      { "<leader>h", function() wk.show({ global = true }) end, desc = "Show All Keybindings" },
      
      -- Git status
      { "<C-g>", desc = "Git Status" },
      
      -- F-keys
      { "<F1>", desc = "Toggle Precognition" },
      { "<F2>", desc = "Toggle Paste Mode" },
      { "<F3>", desc = "Toggle Hardtime" },
      { "<F4>", desc = "Clear all notifications" },
      
      -- Basic operations
      { "<Space>", desc = "Toggle Fold" },
      
      -- LSP Navigation (global keys that work when LSP is attached)
      { "K", desc = "Hover Documentation" },
      { "<C-k>", desc = "Signature Help" },
      { "gd", desc = "Go to Definition" },
      { "gD", desc = "Go to Declaration" },
      { "gi", desc = "Go to Implementation" },
      { "gt", desc = "Go to Type Definition" },
      { "gr", desc = "Show References" },
    })
  end,
}
