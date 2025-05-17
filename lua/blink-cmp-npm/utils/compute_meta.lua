---@param ctx blink.cmp.Context
local function compute_meta(ctx)
  local row = ctx.cursor[1]
  local col = ctx.cursor[2]

  -- get line from buffer, not ctx, to get latest up-to-date value
  -- this resolves some edge cases when autocomplete is not updated after deleting a character
  -- we also restrict completion on the 200 first characters for regex performances
  local line = vim.api.nvim_buf_get_text(0, row - 1, 0, row - 1, 200, {})[1]
  local name = line:match('%s*"([^"]*)"?')
  if name == nil then
    return { line, nil, nil, nil, nil, nil, nil, nil, nil, nil }
  end

  local pos_start_name, pos_end_name = line:find(name, 1, true)
  local pos_second_quote
  local pos_third_quote
  local pos_fourth_quote
  local current_version
  local current_version_matcher
  local find_version = false

  if pos_end_name then
    local _, pos_second_quote_find = line:find('"', pos_end_name and pos_end_name + 1 or 1, true)
    pos_second_quote = pos_second_quote_find
  end

  if pos_second_quote then
    local _, pos_third_quote_find = line:find('"', pos_second_quote and pos_second_quote + 1 or 1, true)
    pos_third_quote = pos_third_quote_find
  end

  if pos_third_quote then
    local _, pos_fourth_quote_find = line:find('"', pos_third_quote and pos_third_quote + 1 or 1, true)
    pos_fourth_quote = pos_fourth_quote_find
  end

  if pos_third_quote and pos_fourth_quote and pos_fourth_quote - pos_third_quote > 1 then
    current_version = line:match('.*".*".*"[~^]?(.*)"')
    current_version_matcher = line:match('.*".*".*"([~^]?).*"')
  end

  if pos_third_quote then
    find_version = col >= pos_third_quote
  end

  return {
    line,
    name,
    pos_start_name,
    pos_end_name,
    pos_second_quote,
    pos_third_quote,
    pos_fourth_quote,
    current_version,
    current_version_matcher,
    find_version,
  }
end

return compute_meta
