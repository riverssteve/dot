-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Restore keys for moving to top and bottom of window to g<x>
vim.keymap.set({ "n", "x" }, "gh", "<s-h>", { desc = "Move cursor to top of window" })
vim.keymap.set({ "n", "x" }, "gm", "<s-m>", { desc = "Move cursor to center of window" })
vim.keymap.set({ "n", "x" }, "gl", "<s-l>", { desc = "Move cursor to bottom of window" })

local wk = require("which-key")
wk.add({
  -- Define a top-level group called AI
  -- the code companion key bindings are stored in the plugin configuration
  { "<leader>a", group = "AI", icon = "󱚦" },

  -- define a group inside code actions for file actions
  { "<leader>cc", group = "File Operations" },
  -- inside this group put file operations
  {
    "<leader>ccc",
    function()
      local filepath = vim.fn.expand("%:.")
      vim.fn.setreg("+", filepath)
      Snacks.notifier.notify("Copied: " .. filepath, "info", { timeout = 1000 })
    end,
    desc = "Copy relative path",
  },
  {
    "<leader>ccs",
    function()
      local filepath = vim.fn.expand("%:.")
      Snacks.notifier.notify("File: " .. filepath, vim.log.levels.INFO, { timeout = 10000 })
    end,
    desc = "Show relative path",
  },
  {
    "<leader>ccd",
    function()
      local filepath = vim.fn.expand("%:.:r"):gsub("/", ".")
      vim.fn.setreg("+", filepath)
      Snacks.notifier.notify("Copied: " .. filepath, "info", { timeout = 1000 })
    end,
    desc = "Copy dot-formatted path",
  },
})
