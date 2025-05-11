---@param a string
---@param b string
---@return boolean
local function semantic_sort(a, b)
	local a_matcher, a_major, a_minor, a_patch = string.match(a.label, "([~^]?)(%d+)%.(%d+)%.(%d+)")
	local b_matcher, b_major, b_minor, b_patch = string.match(b.label, "([~^]?)(%d+)%.(%d+)%.(%d+)")
	if a_major ~= b_major then
		return tonumber(a_major) > tonumber(b_major)
	end
	if a_minor ~= b_minor then
		return tonumber(a_minor) > tonumber(b_minor)
	end
	if a_patch ~= b_patch then
		return tonumber(a_patch) > tonumber(b_patch)
	end
	if a_matcher ~= b_matcher then
		return (a_matcher == "^" and 3 or a_matcher == "~" and 2 or 1)
			> (b_matcher == "^" and 3 or b_matcher == "~" and 2 or 1)
	end
	return true
end

return semantic_sort
