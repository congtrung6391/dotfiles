local lspconfigSetup = require("plugins.lsp.nvim_lspconfig").setup
local cmpSetup = require("plugins.lsp.nvim_cmp").setup

local jsPlugins = require('plugins.lsp.javascript')
local rubyPlugins = require('plugins.lsp.ruby')
local goPlugins = require('plugins.lsp.go')

return {
  -- { 'williamboman/mason.nvim' },
  -- { 'williamboman/mason-lspconfig.nvim' },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "goimports", "gofumpt", "gomodifytags", "impl", "golangci-lint", "delve" } },
  },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  { "onsails/lspkind.nvim" },
  { 'nvim-lua/lsp-status.nvim' },
 
  {
    'hrsh7th/nvim-cmp',
    version = "v0.0.2",
    event = "BufReadPre",
    config = cmpSetup,
  },

  {
    'neovim/nvim-lspconfig',
    version = false,
    dependencies = { "nvim-lua/lsp-status.nvim", "simrat39/inlay-hints.nvim" },
    event = "BufReadPre",
    config = lspconfigSetup,
  },

  jsPlugins,
  rubyPlugins,
  goPlugins,
}
