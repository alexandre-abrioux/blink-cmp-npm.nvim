-- Environement setup
local data_path = vim.fn.stdpath("data")

vim.opt.runtimepath:append(data_path .. "/lazy/nvim-treesitter")
vim.opt.runtimepath:append(vim.fn.getcwd())

local is_cursor_in_dependencies_node = require("blink-cmp-npm.utils.is_cursor_in_dependencies_node")
local parsers = require("nvim-treesitter.parsers")
local ts_configs = require("nvim-treesitter.configs")
local path = "package.json"

ts_configs.setup({
  ensure_installed = { "json" },
  highlight = { enable = false },
})

local force_parsing = function()
  local buf = vim.api.nvim_get_current_buf()
  local lang = parsers.get_buf_lang(buf)
  local parser = parsers.get_parser(buf, lang)
  parser:parse()
end

local create_file = function()
  local file = io.open(path, "w")
  local package_json = [[
{
  "name": "test-package",
  "dependencies": {
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "typescript": "^4.6.3"
  }
}
]]

  assert(file, "Failed to open file for writing")
  file:write(package_json)
  file:close()
end

local cleanup_file = function()
  os.remove(path)
end

describe("is_cursor_in_dependencies_node", function()
  create_file()
  vim.cmd("edit " .. path)

  it("should detect cursor in dependencies", function()
    force_parsing()

    vim.api.nvim_win_set_cursor(0, { 4, 5 })
    local result = is_cursor_in_dependencies_node()
    assert.is_true(result)
  end)

  it("should detect cursor in devDependencies", function()
    vim.api.nvim_win_set_cursor(0, { 7, 5 })
    local result = is_cursor_in_dependencies_node()
    assert.is_true(result)
  end)

  it("should detect cursor outside of dependencies or devDependencies", function()
    vim.api.nvim_win_set_cursor(0, { 7, 5 })
    local result = is_cursor_in_dependencies_node()
    assert.is_true(result)
  end)
  cleanup_file()
end)
