return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Mason setup
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { 
        "lua_ls", 
        "ts_ls", 
        "pyright",
        "omnisharp",
        "html",
        "cssls",
        "jsonls",
        "yamlls",
        "dockerls",
        "terraformls",
        "marksman",
        "ansiblels"
      },
    })

    -- LSP configuration
    local lspconfig = require("lspconfig")

    -- Lua LSP
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })

    -- TypeScript LSP
    lspconfig.ts_ls.setup({})

    -- Python LSP
    lspconfig.pyright.setup({})

    -- C# LSP
    lspconfig.omnisharp.setup({})

    -- HTML LSP
    lspconfig.html.setup({})

    -- CSS LSP
    lspconfig.cssls.setup({})

    -- JSON LSP
    lspconfig.jsonls.setup({})

    -- YAML LSP
    lspconfig.yamlls.setup({})

    -- Docker LSP
    lspconfig.dockerls.setup({})

    -- Terraform LSP
    lspconfig.terraformls.setup({})

    -- Markdown LSP
    lspconfig.marksman.setup({})

    -- Ansible LSP
    lspconfig.ansiblels.setup({})

    -- LSP key mappings
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Setup LSP keybinds for this buffer
        require("keybinds").setup_lsp(ev.buf)
      end,
    })

    -- Kanata filetype detection and configuration
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = "*.kbd",
      callback = function()
        vim.bo.filetype = "kanata"
        vim.bo.commentstring = ";; %s"
        -- Set Lisp-like options for better editing
        vim.bo.lisp = true
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
        -- Enable rainbow parentheses behavior
        vim.opt_local.showmatch = true
        vim.opt_local.matchtime = 2
        -- Better indentation for S-expressions
        vim.opt_local.autoindent = true
        vim.opt_local.smartindent = false
        vim.opt_local.indentexpr = ""
        -- Basic syntax highlighting with kanata-specific keywords
        vim.cmd([[
          syntax clear
          syntax match kanataComment ";;\+.*$"
          syntax keyword kanataDefine def defsrc deflayer defalias defcfg defvar deftemplate contained
          syntax keyword kanataDefine defchords defvirtualkeys defseq contained
          syntax keyword kanataAction tap-hold tap-dance layer-switch layer-while-held contained
          syntax keyword kanataAction one-shot multi cmd macro unicode contained
          syntax keyword kanataAction lctl rctl lalt ralt lsft rsft lmet rmet contained
          syntax keyword kanataAction caps tab ret spc bspc del contained
          syntax match kanataString '"[^"]*"'
          syntax match kanataNumber '\d\+'
          syntax match kanataAlias '@[a-zA-Z0-9_-]\+'
          syntax match kanataVariable '\$[a-zA-Z0-9_-]\+'
          syntax region kanataList start='(' end=')' fold transparent contains=ALL
          " Define highlighting
          hi def link kanataComment Comment
          hi def link kanataDefine Define
          hi def link kanataAction Function
          hi def link kanataString String
          hi def link kanataNumber Number
          hi def link kanataAlias Identifier
          hi def link kanataVariable PreProc
        ]])
        -- Set up formatting keybinds
        vim.keymap.set("n", "=", "=%", { buffer = true, desc = "Format S-expression" })
        vim.keymap.set("v", "=", "=", { buffer = true, desc = "Format selected S-expressions" })
      end,
    })
  end,
}
