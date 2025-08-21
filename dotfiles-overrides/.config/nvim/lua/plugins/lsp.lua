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
  end,
}
