-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Prefer the optional dedicated pynvim environment when it exists.
-- Otherwise let Neovim discover its Python and Node providers from PATH.
local python_host = vim.fn.expand("~/.local/share/uv/virtualenvs/neovim/bin/python3")
if vim.fn.executable(python_host) == 1 then
  vim.g.python3_host_prog = python_host
end

vim.g.lazyvim_python_lsp = "ty"

-- https://stackoverflow.com/questions/53835289/iterm2-cursor-scrolling-with-mouse-enabled-in-vim
-- Here so that I can see this when I inevitably wonder why scrolling inside neovim isn't working :)

-- Sync clipboard with neovim
vim.o.clipboard = "unnamedplus"
