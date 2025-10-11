return {
  {
    "DaikyXendo/nvim-material-icon",
    config = function()
      require 'nvim-web-devicons'.setup {
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
          zsh = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "Zsh"
          }
        },
        -- globally enable different highlight colors per icon (default to true)
        -- if set to false all icons will have the default icon's color
        color_icons = true,
        -- globally enable default icons (default to false)
        -- will get overriden by `get_icons` option
        default = true,
      }
    end
  },
  {
    "nvim-tree/nvim-tree.lua",
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "DaikyXendo/nvim-material-icon",
    },
    config = function()
      local nvim_tree = require "nvim-tree"

      local function on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        -- vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
        -- vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))

        vim.keymap.set('n', 'uu', function()
          vim.cmd("TransferUpload " .. api.tree.get_node_under_cursor().absolute_path)
        end, opts('Upload file or directory'))

        vim.keymap.set('n', 'ud', function()
          vim.cmd("TransferDownload" .. api.tree.get_node().path)
        end, opts('Download file or directory'))

        vim.keymap.set('n', 'uf', function()
          local node = api.tree.get_node()
          local context_dir = node.path
          if node.type ~= "directory" then
            -- if not a directory
            -- one level up
            context_dir = context_dir:gsub("/[^/]*$", "")
          end
          vim.cmd("TransferDirDiff " .. context_dir)
          vim.cmd("Neotree close")
        end, opts('Diff remote'))
      end

      -- pass to setup along with your other options

      nvim_tree.setup {
        on_attach = on_attach,
        disable_netrw = false,
        hijack_netrw = true,
        respect_buf_cwd = true,
        view = {
          width = 50,
          number = true,
          relativenumber = true,
        },
        filters = {
          dotfiles = false
        },
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
      }
    end,
  }
}
