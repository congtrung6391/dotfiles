local lspconfigSetup = require("plugins.lsp.nvim_lspconfig").setup
local cmpSetup = require("plugins.lsp.nvim_cmp").setup

return {
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  { "onsails/lspkind.nvim" },
  { 'nvim-lua/lsp-status.nvim' },
  { 'MunifTanjim/prettier.nvim' },

  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'L3MON4D3/LuaSnip' },
    event = "BufReadPre",
    config = cmpSetup,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = { "nvim-lua/lsp-status.nvim", 'L3MON4D3/LuaSnip' },
    event = "BufReadPre",
    config = lspconfigSetup,
  },

  {
    "pmizio/typescript-tools.nvim",
    event = "BufReadPre",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    config = function()
      require("typescript-tools").setup {
        settings = {
          tsserver_file_preferences = function(ft)
            -- Some "ifology" using `ft` of opened file
            return {
              includeInlayParameterNameHints = "all",
              includeCompletionsForModuleExports = true,
              quotePreference = "auto",
            }
          end,
          tsserver_format_options = function(ft)
            -- Some "ifology" using `ft` of opened file
            return {
              allowIncompleteCompletions = false,
              allowRenameOfImportPath = false,
            }
          end
        },
      }
    end
  }
}
