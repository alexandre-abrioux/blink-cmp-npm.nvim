---@param ctx blink.cmp.Context
---@return string
local function extract_line(ctx)
  -- Get line from buffer, not from blink-cmp's context
  -- in order to get the latest up-to-date value.
  -- This resolves some edge cases when autocomplete is not updated after deleting a character.
  -- We also restrict completion on the 200 first characters for regex performances.
  local row_1 = ctx.cursor[1]
  local row_0 = row_1 - 1
  return vim.api.nvim_buf_get_text(0, row_0, 0, row_0, 200, {})[1]
end

return extract_line
