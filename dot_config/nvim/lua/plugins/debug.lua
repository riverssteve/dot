return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dd",
        function()
          local dap = require("dap")
          local configs = dap.configurations.python or {}
          if #configs == 0 then
            vim.notify("No Python DAP configurations found", vim.log.levels.WARN)
            return
          end
          vim.ui.select(configs, {
            prompt = "Select Python configuration:",
            format_item = function(item)
              return item.name
            end,
          }, function(config)
            if config then
              dap.run(config)
            end
          end)
        end,
        desc = "Run runserver (debug)",
      },
    },
  },
}
