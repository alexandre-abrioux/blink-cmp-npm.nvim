local is_cursor_in_dependencies_node = require("blink-cmp-npm.utils.is_cursor_in_dependencies_node")
local ts = require("nvim-treesitter")

-- treesitter is included with nvim 0.12+
-- but the JSON parser needs to be installed with nvim-treesitter
local setup_treesitter = function()
  ts.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })
  ts.install({ "json" }):wait(3000) -- install the JSON parser synchronously
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
  },
  "peerDependencies": {
    "axios": "^1.20.0"
  }
}]]
  vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, vim.split(package_json, "\n"))
end

describe("is_cursor_in_dependencies_node", function()
  setup_treesitter()
  create_buffer()

  describe("without treesitter", function()
    vim.treesitter.stop()

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

    it("should return true when cursor in peerDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 10, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)

    it("should return true when cursor outside of dependencies or devDependencies or peerDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 1, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)
  end)

  describe("with treesitter", function()
    vim.treesitter.start()
    local parser = assert(vim.treesitter.get_parser())
    parser:parse(true) -- wait for treesitter to parse the buffer (synchronously)

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

    it("should return true when cursor in peerDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 10, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_true(result)
    end)

    it("should return false when cursor outside of dependencies or devDependencies or peerDependencies", function()
      vim.api.nvim_win_set_cursor(0, { 1, 5 })
      local result = is_cursor_in_dependencies_node()
      assert.is_false(result)
    end)
  end)
end)
