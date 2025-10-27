return {
  "folke/which-key.nvim",
  tag = 'v2.1.0',
  lazy = false,
  config = function()
    local whichkey = require "which-key"

    local opts = {
      mode = "n", -- Normal mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = false, -- use `nowait` when creating keymaps
    }

    local mappings = {
      ["1"] = { "<cmd>ToggleTerm<CR>", "Open Terminal" },
      ["2"] = { "<cmd>TransparentToggle<CR>", "Toggle background transparent" },
      ["W"] = { "<cmd>update!<CR>", "Save" },
      ["q"] = { "<cmd>q!<CR>", "Quit" },

      a = {
        name = "AI - CodeCompanian",
        a = { "<cmd>CodeCompanionActions<CR>", "Actions Palette" },
        t = { "<cmd>CodeCompanionChat Toggle<CR>", "Toggle Chat" },
      },

      b = {
        name = "Buffer",
      },

      c = {
        name = "Code",
        a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
      },

      d = {
        name = "Debug"
      },

      C = {
        name = "Circle CI",
        a = { "<cmd>CCMyPipelines<cr>", "List and open" },
        o = { "<cmd>lua require('utils').openCurrentCIBranch()<cr>", "Open current branch" },
      },

      f = {
        name = "Find",
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        h = { "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", "Find Hidden File" },
        b = { "<cmd>Telescope buffers<cr>", "Buffers" },
        g = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
        c = { "<cmd>Telescope commands<cr>", "Commands" },
        e = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
        p = { "<cmd>Telescope projects<cr>", "Projects" },
        s = { "<cmd>Telescope grep_string<cr>", "Grep String" },
        r = { "<cmd>Spectre<cr>", "Replace in file" },
        m = { "<cmd>Telescope bookmarks list<cr>", "Bookmarks" },
      },

      g = {
        name = "Git",
        h = { "GitSigns Hunk" },
        y = {
          "<cmd>lua require'gitlinker'.get_buf_range_url('v', {action_callback = require'gitlinker.actions'.open_in_browser})<cr>",
          "Link",
        },
        z = { "<cmd>lua require('utils.term').git_client_toggle()<CR>", "LazyGit" },
        f = {
          name = "Find",
          f = { "<cmd>Telescope git_status<cr>", "Find Tracked File" },
        }
      },

      w = {
        name = "Window",
        d = { "<cmd>q<CR>", "Delete window" },
        v = { "<cmd>vs<CR>", "Split vertical window" },
        h = { "<C-w>h", "Left" },
        l = { "<C-w>l", "Right" },
      }
    }

    whichkey.setup()
    whichkey.register(mappings, opts)
  end,
}
