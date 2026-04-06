vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  -- matches any gitconfig symlink files in dotfiles repo
  pattern = "*/gitconfig*.symlink",
  callback = function()
    vim.bo.filetype = "gitconfig"
  end,
})
