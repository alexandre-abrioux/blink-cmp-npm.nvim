local is_cursor_in_dependencies_node = require("blink-cmp-npm.utils.is_cursor_in_dependencies_node")
local parsers = require("nvim-treesitter.parsers")
local ts_configs = require("nvim-treesitter.configs")

local setup_treesitter = function()
  ts_configs.setup({
    ensure_installed = { "json" },
    sync_install = true,
    highlight = { enable = false },
  })
end

local create_buffer = function()
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_option_value("filetype", "json", { buf = buf })
  vim.api.nvim_set_current_buf(buf)
  local package_json = [[{
  "name": "test-package",
  "dependencies": {
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "typescript": "^4.6.3"
  }
}]]
  vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, vim.split(package_json, "\n"))
end

local force_parsing = function()
  local lang = parsers.get_buf_lang(0)
  local parser = parsers.get_parser(0, lang)
  parser:parse()
end

describe("is_cursor_in_dependencies_node", function()
  setup_treesitter()
  create_buffer()

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
end)
