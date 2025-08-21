return {
  "tris203/precognition.nvim",
  config = function()
    require("precognition").setup({
      startVisible = false,
      disabled_fts = {
        "NvimTree",
        "startify",
        "help",
        "TelescopePrompt",
      },
    })
  end,
}