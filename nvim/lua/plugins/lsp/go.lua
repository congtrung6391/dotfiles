return {
  {
    'ray-x/guihua.lua',
    run = "cd lua/fzy && make"
  },
  {
    "ray-x/go.nvim",
    event = "BufReadPre",
    version = "0.10.0",
    ft = { "go", 'gomod' },
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

      require("go").setup({
        build_tags = "unit,integration",
        lsp_keymaps = false,
        run_in_floaterm = true,
        lsp_cfg = {
          capabilities = capabilities,
        },
        lsp_inlay_hints = {
          enable = true, -- this is the only field apply to neovim > 0.10
        },
        disable_per_project_cfg = false,
        lsp_on_attach = function(client, bufnr)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true)
          end

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
              h = {
                name = "Go Help",
                c = { "<cmd>GoCmt<CR>", "Add Comment" },
                t = { "<cmd>GoAddTag<CR>", "Add Tag" },
                T = { "<cmd>GoRmTag<CR>", "Remove Tag" },
                c = { "<cmd>GoCmt<CR>", "Add Comment" },
                c = { "<cmd>GoCmt<CR>", "Add Comment" },
              }
            }
          };

          local o = { buffer = bufnr, prefix = "<leader>" }
          whichkey.register(keymap_c, o)

          local keymap_g = {
            name = "Goto",
            d = { "<Cmd>lua vim.lsp.buf.definition()<CR>", "Definition" },
            D = { "<Cmd>lua vim.lsp.buf.declaration()<CR>", "Declaration" },
            h = { "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
            i = { "<cmd>Telescope lsp_implementations<CR>", "Goto Implementation" },
            t = { "<cmd>lua vim.lsp.buf.type_definition()<CR>", "Goto Type Definition" },
            r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
          }

          o = { buffer = bufnr, prefix = "g" }
          whichkey.register(keymap_g, o)
        end
      })
    end,
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  }
}
