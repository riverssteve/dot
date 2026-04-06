-- Extends LazyVim's nvim-cmp config to add Python import transformation on completion
return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")

      -- Hook into confirm_done to transform Python class imports
      cmp.event:on("confirm_done", function(evt)
        local item = evt.entry:get_completion_item()

        -- Only react to Python auto-imports
        if vim.bo.filetype ~= "python" then
          return
        end

        -- Heuristic: completion inserted a class
        if item.kind ~= cmp.lsp.CompletionItemKind.Class then
          return
        end

        -- Defer so LSP edits are applied first
        vim.defer_fn(function()
          require("customs.python_imports").transform_python_class_import_to_module()
        end, 50)
      end)

      return opts
    end,
  },
}
