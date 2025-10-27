return {
  {
    "ray-x/go.nvim",
    event = "BufReadPre",
    version = "0.10.4",
    ft = { "go", 'gomod' },
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lsp_keymaps = false,
      lsp_cfg = true,
      lsp_on_attach = true,
    },
    config = function(lp, opts)
      require("go").setup(opts)

      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require('go.format').goimports()
        end,
        group = format_sync_grp,
      })


      local whichkey = require "which-key"

      local keymap_c = {
        c = {
          f = { "<cmd>lua vim.lsp.buf.format({async = true})<CR>", "Format Document" },
          r = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
        }
      };

      local o = { buffer = bufnr, prefix = "<leader>" }
      whichkey.register(keymap_c, o)

      local keymap_g = {
        name = "Goto",
        -- d = { "<Cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
        -- D = { "<Cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
        -- h = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
        -- i = { "<cmd>Telescope lsp_implementations<CR>", "Goto Implementation" },
        -- t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Goto Type Definition" },
        -- r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
      }

      o = { buffer = bufnr, prefix = "g" }
      whichkey.register(keymap_g, o)
    end,
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  }
}
