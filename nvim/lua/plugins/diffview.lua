return {
  "dlyongemallo/diffview-plus.nvim",
  tag = "v0.39",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    use_icons = true,
    view = {
      default = { layout = "diff1_inline" },
      merge_tool = { layout = "diff3_horizontal" },
      file_history = {
        layout = "diff1_inline",
      },
      inline = {
        -- Choose your style: "unified" or "overleaf"
        style = "overleaf",
      },
    },
    enhanced_diff_hl = true,
    file_panel = {
      listing_style = "tree",
      win_config = { position = "left", width = 70 }, -- Use "auto" to fit content
    },
    hooks = {
      diff_buf_win_enter = function(_, winid, ctx)
        vim.wo[winid].cursorlineopt = "number"

        if ctx.layout_name:match("^diff2") then
          local overrides = nil
          if ctx.symbol == "a" then
            overrides = { DiffChange = "DiffChangeLeft", DiffText = "DiffTextLeft" }
          elseif ctx.symbol == "b" then
            overrides = { DiffChange = "DiffChangeRight", DiffText = "DiffTextRight" }
          end

          if overrides then
            -- Replace prior DiffChange/DiffText entries instead of appending,
            -- since this hook re-runs on every diff window enter.
            local kept = {}
            for entry in vim.gsplit(vim.wo[winid].winhl, ",", { plain = true, trimempty = true }) do
              local from = entry:match("^([^:]+):")
              if from and not overrides[from] then
                table.insert(kept, entry)
              end
            end
            for from, to in pairs(overrides) do
              table.insert(kept, from .. ":" .. to)
            end
            vim.wo[winid].winhl = table.concat(kept, ",")
          end
        end
      end,
    },
    keymaps = {
      view = {
        {
          "n",
          "gf",
          function()
            local view = require("diffview.lib").get_current_view()
            local file = view and view:infer_cur_file()
            if file then
              local line = vim.api.nvim_win_get_cursor(0)[1]
              vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(file.absolute_path))
              pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
            end
          end,
          { desc = "Open file in vertical split in current tabpage" },
        },
      },
      file_panel = {
        {
          "n",
          "gf",
          function()
            local view = require("diffview.lib").get_current_view()
            local file = view and view:infer_cur_file()
            if file then
              vim.cmd("botright vsplit " .. vim.fn.fnameescape(file.absolute_path))
            end
          end,
          { desc = "Open file in vertical split in current tabpage" },
        },
      },
      file_history_panel = {
        {
          "n",
          "gf",
          function()
            local view = require("diffview.lib").get_current_view()
            local file = view and view:infer_cur_file()
            if file then
              vim.cmd("botright vsplit " .. vim.fn.fnameescape(file.absolute_path))
            end
          end,
          { desc = "Open file in vertical split in current tabpage" },
        },
      },
    },
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewFileHistory",
    "DiffviewDiffFiles",
    "DiffviewMergeFiles",
    "DiffviewDiffDirs",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
  },
}
