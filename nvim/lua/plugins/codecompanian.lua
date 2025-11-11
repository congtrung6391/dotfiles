local fmt = string.format

local constants = {
  LLM_ROLE = "llm",
  USER_ROLE = "user",
  SYSTEM_ROLE = "system",
}

return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/mcphub.nvim",
    {
      "echasnovski/mini.diff",
      config = function()
        local diff = require("mini.diff")
        diff.setup({
          -- Disabled by default
          source = diff.gen_source.none(),
        })
      end,
    },
    {
      "HakonHarnes/img-clip.nvim",
      opts = {
        filetypes = {
          codecompanion = {
            prompt_for_file_name = false,
            template = "[Image]($FILE_PATH)",
            use_absolute_path = true,
          },
        },
      },
    },
  },
  config = function()
    local spinner = require("utils.spinner")
    spinner:init()

    require("codecompanion").setup({
      opts = {
        log_level = "ERROR", -- TRACE|DEBUG|ERROR|INFO
        send_code = true,
      },
      strategies = {
        chat = {
          adapter = "gemini_cli",
          keymaps = {
            send = {
              modes = { n = '<CR>', i = '<S-CR>' },
              callback = function(chat)
                vim.cmd("stopinsert")
                chat:submit()
                chat:add_buf_message({ role = "llm", content = "" })
              end,
              index = 1,
              description = "Send",
            }
          }
        },
        inline = {
          adapter = "qwen2.5-coder",
          keymaps = {
            accept_change = {
              modes = { n = "gDa" }, -- Remember this as DiffAccept
            },
            reject_change = {
              modes = { n = "gDr" }, -- Remember this as DiffReject
            },
            always_accept = {
              modes = { n = "gDy" }, -- Remember this as DiffYolo
            },
          },
        },
      },
      display = {
        action_palette = {
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
        chat = {
          show_settings = true,
          window = {
            position = "right",
          },
        },
      },
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              commands = {
                default = {
                  "node",
                  "/Users/austin/.nvm/versions/node/v20.19.5/bin/gemini",
                  "--experimental-acp",
                },
              },
              opts = {
                stream = true,
              },
              defaults = {
                auth_method = "gemini-api-key",
                mcpServers = {},
                timeout = 20000, -- 20 seconds
              },
              env = {
                GEMINI_API_KEY = "AIzaSyBThIQvdZCbsSvLMsQHRRhrF2BxRCU6jBM",
              },
            })
          end,
        },
        http = {
          ['qwen2.5-coder'] = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "qwen2.5-coder-codecompanian", -- Give this adapter a different name to differentiate it from the default ollama adapter
              opts = {
                vision = true,
                stream = true,
              },
              schema = {
                model = {
                  default = "qwen2.5-coder:1.5b",
                },
                num_ctx = {
                  default = 16384,
                },
                think = {
                  default = false,
                },
                keep_alive = {
                  default = "5m",
                },
              },
            })
          end,
        },
      },
      prompt_library = {
        ["Explain"] = {
          strategy = "chat",
          description = "Explain how code in a buffer works",
          opts = {
            index = 6,
            is_default = true,
            is_slash_cmd = false,
            modes = { "v" },
            short_name = "explain",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = constants.SYSTEM_ROLE,
              content = [[When asked to explain code, follow these steps:

1. Identify the programming language.
2. Describe the purpose of the code and reference core concepts from the programming language.
3. Explain each function or significant block of code, including parameters and return values.
4. Highlight any specific functions or methods used and their roles.
5. Provide context on how the code fits into a larger application if applicable.]],
            },
            {
              role = constants.USER_ROLE,
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return fmt(
                  [[Please explain this code from buffer %d:

```%s
%s
```
]],
                  context.bufnr,
                  context.filetype,
                  code
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Unit Tests"] = {
          strategy = "inline",
          description = "Generate unit tests for the selected code",
          opts = {
            index = 7,
            is_default = true,
            is_slash_cmd = false,
            modes = { "v" },
            short_name = "tests",
            auto_submit = true,
            user_prompt = false,
            placement = "new",
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = constants.SYSTEM_ROLE,
              content = [[When generating unit tests, follow these steps:

1. Identify the programming language.
2. Identify the purpose of the function or module to be tested.
3. List the edge cases and typical use cases that should be covered in the tests and share the plan with the user.
4. Generate unit tests using an appropriate testing framework for the identified programming language.
5. Ensure the tests cover:
      - Normal cases
      - Edge cases
      - Error handling (if applicable)
6. Provide the generated unit tests in a clear and organized manner without additional explanations or chat.]],
            },
            {
              role = constants.USER_ROLE,
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return fmt(
                  [[<user_prompt>
Please generate unit tests for this code from buffer %d:

```%s
%s
```
</user_prompt>
]],
                  context.bufnr,
                  context.filetype,
                  code
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Fix code"] = {
          strategy = "chat",
          description = "Fix the selected code",
          opts = {
            index = 8,
            is_default = true,
            is_slash_cmd = false,
            modes = { "v" },
            short_name = "fix",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = constants.SYSTEM_ROLE,
              content = [[When asked to fix code, follow these steps:

1. **Identify the Issues**: Carefully read the provided code and identify any potential issues or improvements.
2. **Plan the Fix**: Describe the plan for fixing the code in pseudocode, detailing each step.
3. **Implement the Fix**: Write the corrected code in a single code block.
4. **Explain the Fix**: Briefly explain what changes were made and why.

Ensure the fixed code:

- Includes necessary imports.
- Handles potential errors.
- Follows best practices for readability and maintainability.
- Is formatted correctly.

Use Markdown formatting and include the programming language name at the start of the code block.]],
            },
            {
              role = constants.USER_ROLE,
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                return fmt(
                  [[Please fix this code from buffer %d:

```%s
%s
```
]],
                  context.bufnr,
                  context.filetype,
                  code
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
        ["Explain LSP Diagnostics"] = {
          strategy = "chat",
          description = "Explain the LSP diagnostics for the selected code",
          opts = {
            index = 9,
            is_default = true,
            is_slash_cmd = false,
            modes = { "v" },
            short_name = "lsp",
            auto_submit = true,
            user_prompt = false,
            stop_context_insertion = true,
          },
          prompts = {
            {
              role = constants.SYSTEM_ROLE,
              content =
              [[You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages. When appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting.]],
            },
            {
              role = constants.USER_ROLE,
              content = function(context)
                local diagnostics = require("codecompanion.helpers.actions").get_diagnostics(
                  context.start_line,
                  context.end_line,
                  context.bufnr
                )

                local concatenated_diagnostics = ""
                for i, diagnostic in ipairs(diagnostics) do
                  concatenated_diagnostics = concatenated_diagnostics
                      .. i
                      .. ". Issue "
                      .. i
                      .. "\n  - Location: Line "
                      .. diagnostic.line_number
                      .. "\n  - Buffer: "
                      .. context.bufnr
                      .. "\n  - Severity: "
                      .. diagnostic.severity
                      .. "\n  - Message: "
                      .. diagnostic.message
                      .. "\n"
                end

                return fmt(
                  [[The programming language is %s. This is a list of the diagnostic messages:

%s
]],
                  context.filetype,
                  concatenated_diagnostics
                )
              end,
            },
            {
              role = constants.USER_ROLE,
              content = function(context)
                local code = require("codecompanion.helpers.actions").get_code(
                  context.start_line,
                  context.end_line,
                  { show_line_numbers = true }
                )
                return fmt(
                  [[
This is the code, for context:

```%s
%s
```
]],
                  context.filetype,
                  code
                )
              end,
              opts = {
                contains_code = true,
              },
            },
          },
        },
      }
    })

    local whichkey = require "which-key"

    local keymap_a = {
      a = {
        p = { "<cmd>CodeCompanionActions<CR>", "Action Palette" },
        c = { "<cmd>CodeCompanionChat Toggle<CR>", "Toggle Chat" },
        C = { "<cmd>CodeCompanionChat<CR>", "New Chat" },
        i = { "<cmd>CodeCompanion<CR>", "Inline Assistant" },
      }
    };

    local keymap_a_v = {
      a = {
        p = { "<cmd>CodeCompanionActions<CR>", "Action Palette" },
        a = { "<cmd>'<,'>CodeCompanion<CR>", "Inline Ask" },
        e = { "<cmd>'<,'>CodeCompanion /explain<CR>", "Explain" },
        t = { "<cmd>'<,'>CodeCompanion /tests<CR>", "Gen tests" },
        f = { "<cmd>'<,'>CodeCompanion /fix<CR>", "Fix" },
      }
    };

    local o = { prefix = "<leader>" }
    local o_v = { mode = 'v', prefix = "<leader>" }
    whichkey.register(keymap_a, o)
    whichkey.register(keymap_a_v, o_v)
  end
}
