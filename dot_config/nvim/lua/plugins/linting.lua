return {
  "dense-analysis/ale",
  config = function()
    vim.g.ale_linters = {
      python = {
        "mypy",
        "trim_whitespace",
      },
    }
    vim.g.ale_linters_explicit = 1
  end,
}
