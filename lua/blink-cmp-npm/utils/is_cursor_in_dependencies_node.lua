---@return boolean
local function is_cursor_in_dependencies_node()
  local bufnr = vim.api.nvim_get_current_buf()
  local node = vim.treesitter.get_node()

  -- not blocking completion if there is no parser for JSON
  if node == nil then
    return true
  end

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
