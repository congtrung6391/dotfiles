return {
  -- 'github/copilot.vim',
  {
    'jacob411/Ollama-Copilot',
    enabled = false,
    event = "BufReadPre",
    opts = {
      model_name = "deepseek-coder:1.3b",
      ollama_url = "http://localhost:11434", -- URL for Ollama server, Leave blank to use default local instance.
      stream_suggestion = true,
      python_command = "python3",
      filetypes = { 'python', "javascript", "typescript", "javascriptreact", "typescriptreact", 'lua', 'vim', "markdown" },
      ollama_model_opts = {
        num_predict = 40,
        temperature = 0.1,
      },
      keymaps = {
        suggestion = '<leader>os',
        reject = '<leader>or',
        insert_accept = '<Tab>',
      },
    }
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
    enabled = false,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
    enabled = false,
  }
}
