local is_cursor_in_dependencies_node = require("blink-cmp-npm.utils.is_cursor_in_dependencies_node")
local parsers = require("nvim-treesitter.parsers")
local ts_configs = require("nvim-treesitter.configs")
local path = "package.json"

local setup_treesitter = function()
  ts_configs.setup({
    ensure_installed = { "json" },
    sync_install = true,
    highlight = { enable = false },
  })
end

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
  setup_treesitter()
  create_file()
  vim.cmd("edit " .. path)

  describe("without treesitter", function()
    vim.cmd("TSDisable json")

    it("should return true when cursor in dependencies", function()
      vim.api.nvim_win_set_cursor(0, { 4, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)

    it("should return true when cursor in devDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 7, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)

    it("should return true when cursor outside of dependencies or devDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 1, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)
  end)

  describe("with treesitter", function()
    vim.cmd("TSEnable json")
    force_parsing()

    it("should return true when cursor in dependencies", function()
      vim.api.nvim_win_set_cursor(0, { 4, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)

    it("should return true when cursor in devDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 7, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)

    it("should return false when cursor outside of dependencies or devDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 1, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_false(result)
    end)
  end)

  cleanup_file()
end)
