-- Kanagawa highlight overrides for plugins that upstream does not cover.
-- Semantic names come from kanagawa's resolved theme (colors.theme) and palette.
local function kanagawa_overrides(colors)
  local t = colors.theme
  local ui, diff, diag, syn = t.ui, t.diff, t.diag, t.syn
  local muted = ui.fg_dim
  return {
    -- diff2 side-specific groups used by the winhl hook in lua/plugins/diffview.lua
    DiffChangeLeft = { bg = diff.delete },
    DiffTextLeft = { bg = "#5a2f35", bold = true },
    DiffChangeRight = { bg = diff.add },
    DiffTextRight = { bg = "#3b5232", bold = true },

    -- diffview
    -- diffview copies DiffDelete's fg into DiffviewDiffAddAsDelete, so set it here
    DiffDelete = { fg = muted },
    DiffviewDiffAddAsDelete = { bg = diff.delete },
    DiffviewDiffDeleteDim = { fg = ui.nontext },
    DiffviewDiffDelete = { link = "DiffviewDiffDeleteDim" },
    DiffviewDiffAdd = { bg = diff.add },
    DiffviewDiffChange = { bg = diff.change },
    DiffviewDiffText = { bg = diff.text, bold = true },
    DiffviewFilePanelTitle = { fg = syn.fun, bold = true },
    DiffviewFilePanelCounter = { fg = syn.keyword, bold = true },
    DiffviewFilePanelFileName = { fg = ui.fg },
    DiffviewFilePanelRootPath = { fg = syn.fun, bold = true },
    DiffviewFilePanelPath = { fg = muted },
    DiffviewFilePanelSelected = { fg = syn.constant, bold = true },
    DiffviewFilePanelInsertions = { fg = diag.ok },
    DiffviewFilePanelDeletions = { fg = diag.error },
    DiffviewFilePanelConflicts = { fg = diag.warning },
    DiffviewFolderName = { fg = syn.fun },
    DiffviewFolderSign = { fg = syn.keyword },
    DiffviewHash = { fg = syn.constant },
    DiffviewReference = { fg = syn.fun },
    DiffviewReflogSelector = { fg = syn.special1 },
    DiffviewStatusAdded = { fg = diag.ok },
    DiffviewStatusUntracked = { fg = diag.ok },
    DiffviewStatusModified = { fg = diag.warning },
    DiffviewStatusRenamed = { fg = diag.warning },
    DiffviewStatusCopied = { fg = diag.warning },
    DiffviewStatusTypeChanged = { fg = diag.warning },
    DiffviewStatusUnmerged = { fg = syn.constant, bold = true },
    DiffviewStatusUnknown = { fg = diag.error },
    DiffviewStatusDeleted = { fg = diag.error },
    DiffviewStatusBroken = { fg = diag.error },
    DiffviewStatusIgnored = { fg = muted },
    DiffviewNormal = { fg = ui.fg, bg = ui.bg_m1 },
    DiffviewWinSeparator = { fg = ui.float.fg_border, bg = ui.bg_m1 },
    DiffviewCursorLine = { bg = ui.bg_p1 },
    DiffviewNonText = { fg = ui.nontext },
    DiffviewStatusLine = { fg = ui.fg_dim, bg = ui.bg_m1 },
    DiffviewStatusLineNC = { fg = muted, bg = ui.bg_m1 },
    DiffviewEndOfBuffer = { fg = ui.bg_m1 },

    -- noice
    NoiceCmdlinePopup = { fg = ui.fg, bg = ui.float.bg },
    NoiceCmdlinePopupBorder = { fg = syn.fun, bg = ui.float.bg },
    NoiceCmdlinePopupTitle = { fg = syn.fun, bg = ui.float.bg, bold = true },
    NoiceCmdlineIcon = { fg = diag.warning },
    NoiceCmdlineIconSearch = { fg = syn.constant },
    NoicePopupmenu = { fg = ui.fg, bg = ui.float.bg },
    NoicePopupmenuBorder = { fg = ui.float.fg_border, bg = ui.float.bg },
    NoiceConfirm = { fg = ui.fg, bg = ui.float.bg },
    NoiceConfirmBorder = { fg = syn.constant, bg = ui.float.bg },
    NoiceMini = { fg = ui.fg_dim, bg = ui.bg_m1 },
    NoiceLspProgressTitle = { fg = ui.fg_dim },
    NoiceLspProgressSpinner = { fg = syn.special1 },
    NoiceLspProgressClient = { fg = syn.keyword },

    -- which-key
    WhichKey = { fg = syn.constant },
    WhichKeyGroup = { fg = syn.fun },
    WhichKeyDesc = { fg = ui.fg },
    WhichKeySeparator = { fg = muted },
    WhichKeyValue = { fg = muted },
    WhichKeyFloat = { bg = ui.float.bg },
    WhichKeyBorder = { fg = ui.float.fg_border, bg = ui.float.bg },

    -- flash
    FlashLabel = { fg = ui.bg, bg = diag.warning, bold = true },
    FlashMatch = { fg = syn.fun, bg = ui.bg_visual },
    FlashCurrent = { fg = ui.bg, bg = syn.constant },
    FlashCursor = { fg = ui.fg, bg = ui.bg_visual },
    FlashBackdrop = { fg = ui.nontext },
    FlashPromptIcon = { fg = syn.constant },

    -- bufferline
    BufferLineFill = { bg = ui.bg_m1 },
    BufferLineBackground = { fg = muted, bg = ui.bg_m1 },
    BufferLineBufferVisible = { fg = ui.fg_dim, bg = ui.bg_m1 },
    BufferLineBufferSelected = { fg = ui.fg, bg = ui.bg, bold = true, italic = true },
    BufferLineIndicatorSelected = { fg = syn.fun, bg = ui.bg },
    BufferLineSeparator = { fg = ui.bg_m1, bg = ui.bg_m1 },
    BufferLineSeparatorSelected = { fg = ui.bg_m1, bg = ui.bg },
    BufferLineModified = { fg = diag.warning, bg = ui.bg_m1 },
    BufferLineModifiedSelected = { fg = diag.warning, bg = ui.bg },
    BufferLineCloseButton = { fg = muted, bg = ui.bg_m1 },
    BufferLineCloseButtonSelected = { fg = ui.fg, bg = ui.bg },
    BufferLineDiagnostic = { fg = diag.error, bg = ui.bg_m1 },
    BufferLineDiagnosticSelected = { fg = diag.error, bg = ui.bg },

    -- markview (markdown rendering)
    MarkviewHeading1 = { fg = colors.palette.peachRed, bold = true },
    MarkviewHeading2 = { fg = syn.constant, bold = true },
    MarkviewHeading3 = { fg = diag.warning, bold = true },
    MarkviewHeading4 = { fg = diag.ok, bold = true },
    MarkviewHeading5 = { fg = syn.fun, bold = true },
    MarkviewHeading6 = { fg = syn.keyword, bold = true },
    MarkviewCode = { bg = ui.bg_m1 },
    MarkviewInlineCode = { fg = syn.string, bg = ui.bg_m1 },
    MarkviewCodeInfo = { fg = muted, bg = ui.bg_m1 },
    MarkviewBlockQuote = { fg = syn.special1 },
    MarkviewCheckboxChecked = { fg = diag.ok },
    MarkviewCheckboxUnchecked = { fg = muted },
    MarkviewCheckboxPending = { fg = diag.warning },
    MarkviewLink = { fg = syn.special1, underline = true },
    MarkviewHyperlink = { fg = syn.special1, underline = true },

    -- alpha (start screen)
    AlphaHeader = { fg = syn.fun },
    AlphaHeaderLabel = { fg = diag.warning },
    AlphaButtons = { fg = syn.special1 },
    AlphaShortcut = { fg = syn.constant },
    AlphaFooter = { fg = muted, italic = true },
    AlphaSpecial = { fg = muted },

    -- illuminate
    IlluminatedWordText = { bg = ui.bg_visual },
    IlluminatedWordRead = { bg = ui.bg_visual },
    IlluminatedWordWrite = { bg = ui.bg_visual, underline = true },

    -- toggleterm
    TermSelect = { fg = ui.bg, bg = syn.fun },
    WinBarActive = { fg = ui.fg, bg = ui.bg },
    WinBarInactive = { fg = muted, bg = ui.bg },

    -- spectre
    SpectreBorder = { fg = ui.nontext },
    SpectreDir = { fg = diag.warning },
    SpectreFile = { fg = syn.fun, bold = true },
    SpectreLnr = { fg = muted },
    SpectreSearch = { fg = ui.bg, bg = diag.warning },
    SpectreReplace = { fg = ui.bg, bg = diag.ok },
  }
end

return {
  -- Color theme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        theme = "wave",
        background = { dark = "wave", light = "lotus" },
        terminalColors = true,
        overrides = kanagawa_overrides,
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
    enabled = false,
  },
  {
    "sainnhe/everforest",
    lazy = false,
    config = function()
      vim.g.everforest_better_performance = 1
      vim.cmd.colorscheme [[everforest]]
    end,
    enabled = false,
  },
  {
    'sainnhe/sonokai',
    lazy = false,
    config = function()
      vim.g.sonokai_style = "atlantis"
      vim.cmd.colorscheme [[sonokai]]
    end,
    enabled = false,
  },
  {
    'maxmx03/dracula.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      ---@type dracula
      local dracula = require "dracula"

      dracula.setup({
        transparent = false,
        on_colors = function(colors, color)
          return {
            -- override or create new colors
            mycolor = "#ffffff",
          }
        end,
        on_highlights = function(colors, color)
          return {
            Normal                  = { fg = colors.mycolor },
            -- Git Diff
            DiffAdd                 = { bg = "#243830", fg = "NONE" },
            DiffChange              = { bg = "#243830", fg = "NONE" },
            DiffText                = { bg = "#345c49", fg = "NONE", bold = true },
            DiffChangeRight         = { bg = "#243830", fg = "NONE" },
            DiffTextRight           = { bg = "#345c49", fg = "NONE", bold = true },
            DiffviewDiffAddAsDelete = { bg = "#3d262c", fg = "NONE" },
            DiffChangeLeft          = { bg = "#3d262c", fg = "NONE" },
            DiffTextLeft            = { bg = "#63333e", fg = "NONE", bold = true },
            DiffDelete              = { bg = "NONE", fg = "#3b3f51" },
            DiffviewDiffDelete      = { bg = "NONE", fg = "#3b3f51" },
            -- DiffAdd                 = { bg = "#1E3A24", fg = "NONE" }, -- Soft green background for additions
            -- DiffDelete              = { bg = "#4A1D1D", fg = "NONE" }, -- Soft red background for deletions
            -- DiffChange              = { bg = "#2D3748", fg = "NONE" }, -- Soft grey/blue background for changes
            -- DiffText                = { bg = "#1A365D", fg = "NONE" }, -- Highlighted inner-line changes
          }
        end,
        plugins = {
          ["nvim-treesitter"] = true,
          ["nvim-lspconfig"] = true,
          ["nvim-navic"] = true,
          ["nvim-cmp"] = true,
          ["indent-blankline.nvim"] = true,
          ["neo-tree.nvim"] = true,
          ["nvim-tree.lua"] = true,
          ["which-key.nvim"] = true,
          ["dashboard-nvim"] = true,
          ["gitsigns.nvim"] = true,
          ["neogit"] = true,
          ["todo-comments.nvim"] = true,
          ["lazy.nvim"] = true,
          ["telescope.nvim"] = true,
          ["noice.nvim"] = true,
          ["hop.nvim"] = true,
          ["mini.statusline"] = true,
          ["mini.tabline"] = true,
          ["mini.starter"] = true,
          ["mini.cursorword"] = true,
        }
      })
      vim.cmd.colorscheme 'dracula'
      vim.cmd.colorscheme 'dracula-soft'
    end,
    enabled = false,
  },
  {
    'shaunsingh/nord.nvim',
    lazy = false,
    config = function()
      vim.g.nord_contrast = true
      vim.g.nord_borders = false
      vim.g.nord_disable_background = true
      vim.g.nord_cursorline_transparent = false
      vim.g.nord_enable_sidebar_background = false
      vim.g.nord_italic = true
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_bold = true
      vim.cmd.colorscheme [[nord]]
    end,
    enabled = false,
  },
}
