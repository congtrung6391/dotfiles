local lspconfigSetup = require("plugins.lsp.nvim_lspconfig").setup
local cmpSetup = require("plugins.lsp.nvim_cmp").setup

local jsPlugins = require('plugins.lsp.javascript')
local rubyPlugins = require('plugins.lsp.ruby')
local goPlugins = require('plugins.lsp.go')

return {
  -- { 'williamboman/mason.nvim' },
  -- { 'williamboman/mason-lspconfig.nvim' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'L3MON4D3/LuaSnip' },
  { "onsails/lspkind.nvim" },
  { 'nvim-lua/lsp-status.nvim' },

  {
    'tzachar/cmp-ai',
    dependencies = 'nvim-lua/plenary.nvim',
    ft = { "markdown", "javascript", "javascriptreact", "typescript", "typescriptreact", "go" },
    config = function()
      local cmp_ai = require('cmp_ai.config')

      cmp_ai:setup({
        max_lines = 100,
        provider = 'Ollama',
        provider_options = {
          -- auto_unload = false, -- Set to true to automatically unload the model when
          -- exiting nvim.

          -- model = 'codegemma:2b-code',
          -- prompt = function(lines_before, lines_after)
          --   return lines_before
          -- end,

          model = 'qwen2.5-coder:0.5b',
          prompt = function(lines_before, lines_after)
            -- You may include filetype and/or other project-wise context in this string as well.
            -- Consult model documentation in case there are special tokens for this.
            return "<|fim_prefix|>" .. lines_before .. "<|fim_suffix|>" .. lines_after .. "<|fim_middle|>"
          end,

          suffix = function(lines_after)
            return lines_after
          end,

          -- raw_response_cb = function(response)
          --   -- the `response` parameter contains the raw response (JSON-like) object.
          --   -- vim.notify(vim.inspect(response)) -- show the response as a lua table
          --   vim.g.ai_raw_response = response  -- store the raw response in a global
          -- end,
        },
        -- notify = true,
        -- notify_callback = function(msg)
        --   vim.notify(msg)
        -- end,
        -- log_errors = true,
        run_on_every_keystroke = false,
        max_timeout_seconds = 10,
      })
    end
  },
  {
    'hrsh7th/nvim-cmp',
    version = false,
    event = "BufReadPre",
    config = cmpSetup,
    dependencies = { 'tzachar/cmp-ai' }
  },

  {
    'neovim/nvim-lspconfig',
    version = false,
    dependencies = { "nvim-lua/lsp-status.nvim" },
    event = "BufReadPre",
    config = lspconfigSetup,
  },

  jsPlugins,
  rubyPlugins,
  goPlugins,
}
