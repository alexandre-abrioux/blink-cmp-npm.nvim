---@param ctx blink.cmp.Context
local function compute_meta(ctx)
	-- restrict completion on lines < 200 characters for performances
	local line = ctx.line:sub(1, 200)
	local name = line:match('%s*"([^"]*)"?')
	if name == nil then
		return { line, nil, nil, nil, nil, nil, nil, nil, nil, nil }
	end

	local _, pos_end_name = line:find(name, 1, true)
	local pos_second_quote
	local pos_third_quote
	local pos_fourth_quote
	local current_version
	local current_version_matcher
	local last_quote_present = false
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

	last_quote_present = pos_fourth_quote and pos_fourth_quote > pos_third_quote or false

	if pos_third_quote then
		local col = ctx.cursor[2]
		find_version = col >= pos_third_quote
	end

	return {
		line,
		name,
		pos_end_name,
		pos_second_quote,
		pos_third_quote,
		pos_fourth_quote,
		current_version,
		current_version_matcher,
		last_quote_present,
		find_version,
	}
end

return compute_meta
