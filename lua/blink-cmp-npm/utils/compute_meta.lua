---@param line string
---@param ctx blink.cmp.Context
local function compute_meta(line, ctx)
  -- protect regex performance
  assert(#line <= 200)

  local col = ctx.cursor[2]
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
    local _, pos_second_quote_find = line:find('"', pos_end_name + 1, true)
    pos_second_quote = pos_second_quote_find
  end

  if pos_second_quote then
    local _, pos_third_quote_find = line:find('"', pos_second_quote + 1, true)
    pos_third_quote = pos_third_quote_find
  end

  if pos_third_quote then
    local _, pos_fourth_quote_find = line:find('"', pos_third_quote + 1, true)
    pos_fourth_quote = pos_fourth_quote_find
  end

  if pos_third_quote then
    find_version = col >= pos_third_quote
  end

  if find_version then
    local line_up_to_cursor = line:sub(0, col)
    current_version_matcher, current_version = line_up_to_cursor:match('^[^"]*"[^"]*"[^"]*"([~^]?)([^"]*)"?$')
  end

  return {
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
