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
    vim.keymap.set("n", "<F1>", function()
      require("precognition").toggle()
    end, { desc = "Toggle Precognition" })
  end,
}