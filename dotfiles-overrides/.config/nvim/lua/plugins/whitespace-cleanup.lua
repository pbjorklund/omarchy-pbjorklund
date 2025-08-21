-- Automatic trailing whitespace cleanup
return {
  name = "whitespace-cleanup",
  dir = vim.fn.stdpath("config"),
  config = function()
    -- Strip trailing whitespace on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      command = [[%s/\s\+$//e]],
    })
  end,
}