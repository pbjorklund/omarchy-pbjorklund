return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function()
    require("hardtime").setup({
      enabled = false,
      max_time = 1000,
      max_count = 3,
      hint = true,
      notification = true,
      timeout = 3000,
      restriction_mode = "block",
      disabled_filetypes = {
        ["NvimTree"] = true,
        ["startify"] = true,
        ["help"] = true,
        ["TelescopePrompt"] = true,
        ["lazy"] = true,
        ["mason"] = true,
        ["copilot-chat"] = true,
      },
      restricted_keys = {
        ["h"] = { "n", "x" },
        ["j"] = { "n", "x" },
        ["k"] = { "n", "x" },
        ["l"] = { "n", "x" },
        ["w"] = { "n", "x" },
        ["e"] = { "n", "x" },
        ["b"] = { "n", "x" },
        ["W"] = { "n", "x" },
        ["E"] = { "n", "x" },
        ["B"] = { "n", "x" },
        ["+"] = { "n", "x" },
        ["gj"] = { "n", "x" },
        ["gk"] = { "n", "x" },
        ["<C-M>"] = { "n", "x" },
        ["<C-N>"] = { "n", "x" },
        ["<C-P>"] = { "n", "x" },
      },
      hints = {
        -- Command-line alternatives for common patterns
        ["ggVGy"] = {
          message = function() return "Use :%y instead of ggVGy to copy entire buffer" end,
          length = 5,
        },
        ["ggVG[dc]"] = {
          message = function(keys)
            local op = keys:sub(5,5)
            return "Use :%" .. op .. " instead of " .. keys .. " for entire buffer"
          end,
          length = 5,
        },
        ["ggVG="] = {
          message = function() return "Use gg=G instead of ggVG= to format entire buffer" end,
          length = 5,
        },
        -- Line navigation improvements
        ["[jk][jk][jk][jk]+"] = {
          message = function() return "Use relative line numbers (5j, 10k) or search (/, ?) instead" end,
          length = 4,
        },
        ["gg[jk]%d+"] = {
          message = function(keys)
            local num = keys:match("%d+")
            return "Use :" .. num .. " to jump to line " .. num .. " directly"
          end,
          length = 6,
        },
        -- Word movement spam prevention
        ["[wbe][wbe][wbe]"] = {
          message = function() return "Use f/t for character jumps, or / for search instead" end,
          length = 3,
        },
        ["[WBE][WBE][WBE]"] = {
          message = function() return "Use search (/, *, #) for longer distance movement" end,
          length = 3,
        },
        -- Better horizontal navigation
        ["[hl][hl][hl][hl]+"] = {
          message = function() return "Use w/b/e for word movement, f/t/F/T for character jumps" end,
          length = 4,
        },
        -- Search-based movement hints
        ["[jk]+[/?]"] = {
          message = function() return "Search first with /, then use n/N to navigate results" end,
          length = 4,
        },
        -- Text object encouragement
        ["v[ia][wsp][dcy]"] = {
          message = function(keys)
            return "Use " .. keys:sub(4) .. keys:sub(2,3) .. " instead of " .. keys
          end,
          length = 4,
        },
        ["v[%({%[\"'][dcy]"] = {
          message = function(keys)
            local bracket = keys:sub(2,2)
            return "Use " .. keys:sub(3) .. "i" .. bracket .. " instead of " .. keys
          end,
          length = 3,
        },
        -- Better deletion with insert
        ["d[wbe]i"] = {
          message = function(keys) return "Use c" .. keys:sub(2,2) .. " instead of " .. keys end,
          length = 3,
        },
        ["d[tTfF].i"] = {
          message = function(keys) return "Use c" .. keys:sub(2,3) .. " instead of " .. keys end,
          length = 4,
        },
        -- Encourage marks and jumps
        ["[jk]%d%d+[jk]%d%d+"] = {
          message = function() return "Use ma to set mark, then `a to return. Or use Ctrl-o/i for jump history" end,
          length = 8,
        },
        -- Better selection patterns
        ["V[jk]%d+[dcy=<>]"] = {
          message = function(keys)
            local op = keys:match("[dcy=<>]")
            local num = keys:match("%d+")
            return "Use " .. op .. keys:sub(2,2) .. num .. " instead of " .. keys
          end,
          length = 6,
        },
        -- Repetitive operations
        ["dd[jk]dd"] = {
          message = function() return "Use d2d or 2dd to delete multiple lines at once" end,
          length = 5,
        },
        ["yy[jk]yy"] = {
          message = function() return "Use y2y or 2yy to yank multiple lines at once" end,
          length = 5,
        },
        -- Better indentation
        [">>[jk]>>"] = {
          message = function() return "Use 2>> to indent multiple lines, or V + select + >" end,
          length = 5,
        },
        ["<<[jk]<<"] = {
          message = function() return "Use 2<< to unindent multiple lines, or V + select + <" end,
          length = 5,
        },
        -- Search word under cursor
        ["[/?].*<CR>[jkhl]+"] = {
          message = function() return "Use */# to search word under cursor, then n/N to navigate" end,
          length = 6,
        },
        -- Better joining lines
        ["[jk]J"] = {
          message = function() return "Move to line first, then use J. Or use :join command" end,
          length = 2,
        },
        -- Encourage using counts
        ["x[hl]x"] = {
          message = function() return "Use 2x or d2l to delete multiple characters" end,
          length = 3,
        },
        -- Pattern for going to line then beginning
        ["%d+G%^"] = {
          message = function(keys)
            local num = keys:match("%d+")
            return "Use :" .. num .. " instead of " .. keys .. " to go to line " .. num
          end,
          length = 4,
        },
      },
      callback = function(msg)
        vim.notify(msg, vim.log.levels.WARN, { title = "Hardtime" })
      end,
    })
  end,
}
