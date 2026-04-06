return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd" },
        python = { "ruff_fix", "ruff_format" },
      },
      default_format_opts = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
  {
    "jparise/vim-graphql",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function()
      require("config.render_markdown").setup()
    end,
  },
}
