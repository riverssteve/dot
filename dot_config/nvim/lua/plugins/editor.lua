return {
  {
    "tpope/vim-unimpaired",
  },
  {
    dir = "~/code/kraken/kraken.nvim",
    enabled = function()
      return vim.fn.isdirectory(vim.fn.expand("~/code/kraken/kraken.nvim")) == 1
    end,
    opts = {},
  },
}
