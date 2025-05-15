local ts_parsers = require("nvim-treesitter.parsers")
local ts_utils = require("nvim-treesitter.ts_utils")

---@return boolean
local function is_cursor_in_dependencies_node()
  local bufnr = vim.api.nvim_get_current_buf()

  -- not blocking completion if there is no parser for JSON
  if not ts_parsers.has_parser("json") then
    return true
  end

  local node = ts_utils.get_node_at_cursor()

  while node do
    local node_type = node:type()
    if node_type == "pair" then
      local key_node = node:child(0)
      if key_node and key_node:type() == "string" then
        local key_text = vim.treesitter.get_node_text(key_node, bufnr)
        if key_text == '"dependencies"' or key_text == '"devDependencies"' then
          return true
        end
      end
    end
    node = node:parent()
  end

  return false
end

return is_cursor_in_dependencies_node
