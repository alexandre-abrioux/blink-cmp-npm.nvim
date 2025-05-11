--- @module 'blink.cmp'

--- @class blink-cmp-npm.Source: blink.cmp.Source
--- @field opts blink-cmp-npm.Options
local source = {}

---@class blink-cmp-npm.Options: blink.cmp.PathOpts
---@field ignore? table
---@field only_semantic_versions? boolean
---@field only_latest_version? boolean
local default_opts = {
	ignore = {},
	only_semantic_versions = true,
	only_latest_version = false,
}

---@param opts blink-cmp-npm.Options
function source.new(opts)
	local self = setmetatable({}, { __index = source })
	self.opts = vim.tbl_deep_extend("force", default_opts, opts)
	return self
end

function source:enabled()
	local filename = vim.fn.expand("%:t")
	return filename == "package.json"
end

function source:get_trigger_characters()
	return { '"' }
end

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

function source:get_completions(ctx, callback)
	local meta = compute_meta(ctx)
	local _, name, _, _, pos_third_quote, _, current_version, current_version_matcher, _, find_version = unpack(meta)

	if not name then
		return function() end
	end

	local kind = require("blink.cmp.types").CompletionItemKind.Module
	if find_version then
		assert(pos_third_quote)
		if self.opts.only_latest_version then
			vim.system(
				{
					"npm",
					"info",
					name,
					"version",
					"--no-update-notifier",
				},
				nil,
				function(result)
					if result.code ~= 0 then
						return
					end

					local lines = vim.split(result.stdout, "\n")
					local version = lines[1]
					if not version then
						return
					end

					--- @type lsp.CompletionItem[]
					local items = {}

					--- @type lsp.CompletionItem
					local item_minor = {
						label = "^" .. version,
						sortText = version .. "_1",
						kind = kind,
					}

					--- @type lsp.CompletionItem
					local item_patch = {
						label = "~" .. version,
						sortText = version .. "_2",
						kind = kind,
					}

					--- @type lsp.CompletionItem
					local item_strict = {
						label = version,
						sortText = version .. "_3",
						kind = kind,
					}

					table.insert(items, item_minor)
					table.insert(items, item_patch)
					table.insert(items, item_strict)

					callback({
						items = items,
						is_incomplete_backward = true,
						is_incomplete_forward = true,
					})
				end
			)
		else
			vim.system(
				{
					"npm",
					"info",
					name,
					"versions",
					"--json",
					"--no-update-notifier",
				},
				nil,
				function(result)
					if result.code ~= 0 then
						return
					end

					--- @type lsp.CompletionItem[]
					local items = {}

					-- populate items
					local versions = vim.json.decode(result.stdout)
					for _, version in ipairs(versions) do
						if self.opts.only_semantic_versions and not string.match(version, "^%d+%.%d+%.%d+$") then
							goto continue
						else
							for _, ignoreString in ipairs(self.opts.ignore) do
								if string.match(version, ignoreString) then
									goto continue
								end
							end
						end
						if current_version and version:sub(1, #current_version) ~= current_version then
							goto continue
						end
						if not current_version or current_version_matcher == "^" then
							table.insert(items, { label = "^" .. version, kind = kind })
						end
						if not current_version or current_version_matcher == "~" then
							table.insert(items, { label = "~" .. version, kind = kind })
						end
						if not current_version or current_version_matcher == "" then
							table.insert(items, { label = version, kind = kind })
						end
						::continue::
					end

					-- order result
					table.sort(items, function(a, b)
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
					end)

					-- add sorting property for blink.cmp
					for index, item in ipairs(items) do
						items[index] = vim.tbl_deep_extend("force", item, {
							sortText = index,
						})
					end

					callback({
						items = items,
						is_incomplete_backward = true,
						is_incomplete_forward = true,
					})
				end
			)
		end
	else
		vim.system(
			{
				"npm",
				"search",
				"--json",
				"--no-update-notifier",
				name,
			},
			nil,
			function(result)
				if result.code ~= 0 then
					return
				end

				--- @type lsp.CompletionItem[]
				local items = {}

				-- populate items
				local npm_items = vim.json.decode(result.stdout)
				for npm_item_key, npm_item in ipairs(npm_items) do
					table.insert(items, {
						kind = kind,
						label = npm_item.name,
						sortText = npm_item_key,
						documentation = {
							kind = "markdown",
							value = "# `"
								.. npm_item.name
								.. "`\n\n"
								.. npm_item.links.npm
								.. (npm_item.links.homepage and ("\n" .. npm_item.links.homepage) or "")
								.. "\n\n"
								.. "## Latest\n"
								.. npm_item.version
								.. " ("
								.. npm_item.date
								.. ")"
								.. "\n\n"
								.. (npm_item.description and "## About\n" or "")
								.. (npm_item.description and npm_item.description:sub(1, 200) or "")
								.. (npm_item.description and #npm_item.description > 200 and "..." or "")
								.. (npm_item.description and "\n\n" or "")
								.. (#npm_item.keywords > 0 and "## Keywords\n" or "")
								.. table.concat(npm_item.keywords, " "),
						},
					})
				end

				callback({
					items = items,
					is_incomplete_backward = true,
					is_incomplete_forward = true,
				})
			end
		)
	end
end

function source:execute(ctx, item, callback)
	local meta = compute_meta(ctx)
	local _, _, _, _, _, _, _, _, last_quote_present, _ = unpack(meta)
	local insert_text = item.label
	if item.insertText then
		insert_text = item.insertText
	end
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)
	if last_quote_present then
		vim.api.nvim_feedkeys('ci"' .. insert_text, "n", true)
	else
		local line_last_char = ctx.line:sub(#ctx.line)
		local line_end_with_quotes = line_last_char and line_last_char == '"' or false
		local col = ctx.cursor[2]
		if line_end_with_quotes and col == #ctx.line then
			vim.api.nvim_feedkeys("a" .. insert_text .. '"', "n", true)
		else
			vim.api.nvim_feedkeys('F"c$' .. '"' .. insert_text .. '"', "n", true)
		end
	end
	callback()
end

return source
