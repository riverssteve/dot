local dap = require("dap")
local django_clients = {
  { label = "OESGB Test", configuration = "OESGBSupportSiteTest" },
}

require("dap-python").setup(vim.g.python3_host_prog)

local function select_django_client()
  local co = coroutine.running()
  local labels = vim.tbl_map(function(c)
    return c.label
  end, django_clients)
  vim.ui.select(labels, { prompt = "Select Django client:" }, function(choice)
    coroutine.resume(co, choice)
  end)
  local selected = coroutine.yield()
  if not selected then
    return {}
  end
  for _, client in ipairs(django_clients) do
    if client.label == selected then
      return { DJANGO_CONFIGURATION = client.configuration }
    end
  end
  return {}
end

dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "localdev runserver",
    program = "${workspaceFolder}/src/manage.py",
    args = { "runserver", "--noreload" },
    django = true,
    envFile = "${workspaceFolder}/data/local.env",
    env = select_django_client,
  },
}
