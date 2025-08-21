return {
  "s1n7ax/nvim-window-picker",
  version = "2.*",
  config = function()
    require("window-picker").setup({
      filter_rules = {
        include_current_win = false,
        autoselect_one = true,
        bo = {
          filetype = { "neo-tree", "neo-tree-popup", "notify" },
          buftype = { "terminal", "quickfix" },
        },
      },
      highlights = {
        statusline = {
          focused = {
            fg = "#ededed",
            bg = "#e35e4f",
            bold = true,
          },
          unfocused = {
            fg = "#ededed",
            bg = "#44cc41",
            bold = true,
          },
        },
        winbar = {
          focused = {
            fg = "#ededed",
            bg = "#e35e4f",
            bold = true,
          },
          unfocused = {
            fg = "#ededed",
            bg = "#44cc41",
            bold = true,
          },
        },
      },
    })

    -- Key mapping for window picker
    vim.keymap.set("n", "<leader>w", function()
      local picked_window_id = require("window-picker").pick_window() or vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(picked_window_id)
    end, { desc = "Pick a window" })
  end,
}