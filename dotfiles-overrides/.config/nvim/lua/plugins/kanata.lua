-- Kanata keyboard configuration support
return {
  name = "kanata-support",
  dir = vim.fn.stdpath("config"),
  config = function()
    -- Set up kanata filetype detection and features
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = "*.kbd",
      callback = function()
        -- Set filetype
        vim.bo.filetype = "kanata"
        
        -- Basic editor settings
        vim.bo.commentstring = ";; %s"
        vim.bo.expandtab = true
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.softtabstop = 2
        
        -- Simple syntax highlighting for kanata
        vim.cmd([[
          syntax match kanataComment ";;.*$"
          syntax match kanataKeyword "\v<(defcfg|defsrc|deflayer|defalias)>"
          syntax match kanataAlias "@\w\+"
          syntax region kanataCommand start="(" end=")" contains=kanataKeyword,kanataAlias
          
          highlight link kanataComment Comment
          highlight link kanataKeyword Keyword
          highlight link kanataAlias Identifier
          highlight link kanataCommand Function
        ]])
      end,
    })
  end,
}

--[[
# Kanata Neovim Plugin

## Overview
Provides kanata keyboard configuration (.kbd) file support with:
- Filetype detection and basic syntax highlighting  
- Use existing `,af` for alignment

## Features
- **Filetype support**: Automatic detection of .kbd files
- **Syntax highlighting**: Keywords, aliases, commands, comments
- **Alignment**: Use existing `,af` command for alignment

## Usage
- `,af` - Format and align (same as other file types)
- Select text in visual mode, then `,af` for manual alignment

The plugin provides the foundation; use existing alignment tools for formatting.
--]]