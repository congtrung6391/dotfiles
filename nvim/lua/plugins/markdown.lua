return {
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  --   ft = { "markdown", "codecompanion" },
  --   build = function() vim.fn["mkdp#util#install"]() end,
  -- },
  -- {
  --   "OXY2DEV/markview.nvim",
  --   lazy = false,
  --   opts = {
  --     preview = {
  --       filetypes = { "markdown", "codecompanion" },
  --       ignore_buftypes = {},
  --     },
  --   },
  -- },
  --   {
  --   "delphinus/md-render.nvim",
  --   tag = "v3.13.4",
  --   dependencies = {
  --     { "nvim-tree/nvim-web-devicons", version = "*" }, -- optional
  --     { "delphinus/budoux.lua", version = "v1.0.2" }, -- optional
  --   },
  --   keys = {
  --     { "<leader>mp", "<Plug>(md-render-preview)", desc = "Markdown preview (toggle)" },
  --     { "<leader>mt", "<Plug>(md-render-preview-tab)", desc = "Markdown preview in tab (toggle)" },
  --   },
  -- }
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
    ft = { "markdown", "codecompanion" },
    opts = {
      code = {
        disable = { "mermaid", "plantuml", "d2", "gnuplot" },
      },
    },
  },
}
