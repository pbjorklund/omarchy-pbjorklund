return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-h>"] = "which_key"
          }
        },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/*",
          "--glob=!node_modules/*",
        },
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
}