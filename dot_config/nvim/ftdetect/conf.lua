if vim.filetype then
  vim.filetype.add({
    pattern = {
      [".*%.env"] = "conf",
      ["%.env%..*"] = "conf",
    },
  })
end
