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
  end,
}
