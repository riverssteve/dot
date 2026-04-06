return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("config.lualine").setup_theme()
    end,
  },
  { "folke/noice.nvim", enabled = true },
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        ["notification.ale"] = {
          wrap = false,
        },
      },
      picker = {
        sources = {
          files = {
            hidden = true, -- show hidden files
            ignored = false,
            exclude = {
              "*.pyc",
              ".git",
              ".mypy_cache",
              ".pytest_cache",
              "__pycache__",
              "node_modules",
            },
          },
          explorer = {
            replace_netrw = true,
            trash = true,
            hidden = true,
          },
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    -- At some point investigate if we can remove this restriction
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      display = {
        action_palette = {
          provider = "default",
        },
      },
      strategies = {
        -- Change the default chat adapter and model
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = {
                default = "claude-sonnet-4-5",
              },
            },
          })
        end,
      },
    },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "Actions" },
      { "<leader>ai", "<cmd>CodeCompanion<cr>", desc = "Inline" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add to Chat" },
    },
  },
}
