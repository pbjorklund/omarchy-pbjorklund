-- Enhanced Kanata (.kbd) file editing support
return {
  {
    "gpanders/nvim-parinfer",
    event = "VeryLazy",
    config = function()
      -- Enable parinfer for kanata files
      vim.g.parinfer_filetypes = { "clojure", "scheme", "lisp", "racket", "hy", "fennel", "janet", "cljc", "kanata" }
      vim.g.parinfer_mode = "smart"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Use lisp parser for .kbd files since kanata is lisp-like
      vim.treesitter.language.register("lisp", "kanata")
      -- Ensure lisp is installed
      if not vim.tbl_contains(opts.ensure_installed, "lisp") then
        table.insert(opts.ensure_installed, "lisp")
      end
    end,
  },
  {
    -- Better rainbow parentheses
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          kanata = rainbow_delimiters.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
          kanata = "rainbow-delimiters",
        },
      }
    end,
  },
}