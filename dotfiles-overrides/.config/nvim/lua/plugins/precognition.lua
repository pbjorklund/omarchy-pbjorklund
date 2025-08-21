return {
  "tris203/precognition.nvim",
  config = function()
    require("precognition").setup({
      disabled_fts = {
        "NvimTree",
        "startify",
        "help",
        "TelescopePrompt",
      },
    })

  end,
}