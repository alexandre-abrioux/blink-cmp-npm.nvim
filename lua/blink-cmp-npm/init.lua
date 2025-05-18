local compute_meta = require("blink-cmp-npm.utils.compute_meta")
local extract_line = require("blink-cmp-npm.utils.extract_line")
local generate_doc = require("blink-cmp-npm.utils.generate_doc")
local ignore_version = require("blink-cmp-npm.utils.ignore_version")
local is_cursor_in_dependencies_node = require("blink-cmp-npm.utils.is_cursor_in_dependencies_node")
local semantic_sort = require("blink-cmp-npm.utils.semantic_sort")

---@module 'blink.cmp'
---@class blink-cmp-npm.Source: blink.cmp.Source
---@field opts blink-cmp-npm.Options
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

function source:get_completions(ctx, callback)
  local is_in_dependencies_node = is_cursor_in_dependencies_node()

  if not is_in_dependencies_node then
    return function() end
  end

  local line = extract_line(ctx)
  local meta = compute_meta(line, ctx)
  local name, _pos_start_name, _pos_end_name, _pos_second_quote, _pos_third_quote, _pos_fourth_quote, current_version, current_version_matcher, find_version =
    unpack(meta)

  if not name then
    return function() end
  end

  local kind = require("blink.cmp.types").CompletionItemKind.Module
  if find_version then
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

          ---@type lsp.CompletionItem[]
          local items = {}

          ---@type lsp.CompletionItem
          local item_minor = {
            label = "^" .. version,
            sortText = version .. "_1",
            kind = kind,
          }

          ---@type lsp.CompletionItem
          local item_patch = {
            label = "~" .. version,
            sortText = version .. "_2",
            kind = kind,
          }

          ---@type lsp.CompletionItem
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

          ---@type lsp.CompletionItem[]
          local items = {}

          -- populate items
          ---@type string[]
          local versions = vim.json.decode(result.stdout)
          for _, version in ipairs(versions) do
            local version_ignored = ignore_version(version, current_version, self.opts)
            if not version_ignored then
              if not current_version or current_version_matcher == "^" then
                table.insert(items, { label = "^" .. version, kind = kind })
              end
              if not current_version or current_version_matcher == "~" then
                table.insert(items, { label = "~" .. version, kind = kind })
              end
              if not current_version or current_version_matcher == "" then
                table.insert(items, { label = version, kind = kind })
              end
            end
          end

          -- order result
          table.sort(items, semantic_sort)

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

        ---@type lsp.CompletionItem[]
        local items = {}

        -- populate items
        ---@type NpmPackage[]
        local npm_items = vim.json.decode(result.stdout)
        for npm_item_key, npm_item in ipairs(npm_items) do
          table.insert(items, {
            kind = kind,
            label = npm_item.name,
            sortText = npm_item_key,
            documentation = {
              kind = "markdown",
              value = generate_doc(npm_item),
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

---@param ctx blink.cmp.Context
---@param insert_text string
---@param pos_first_quote integer
---@param pos_second_quote integer | nil
---@param pos_end_line integer
local function replace_text(ctx, insert_text, pos_first_quote, pos_second_quote, pos_end_line)
  local row_1 = ctx.cursor[1]
  local row_0 = row_1 - 1
  if pos_second_quote then
    vim.api.nvim_buf_set_text(0, row_0, pos_first_quote, row_0, pos_second_quote - 1, { insert_text })
  else
    insert_text = insert_text .. '"'
    vim.api.nvim_buf_set_text(0, row_0, pos_first_quote, row_0, pos_end_line, { insert_text })
  end
  vim.api.nvim_win_set_cursor(0, { row_1, pos_first_quote + #insert_text })
end

function source:execute(ctx, item, callback)
  local line = extract_line(ctx)
  local meta = compute_meta(line, ctx)
  local _name, pos_start_name, _pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, _current_version, _current_version_matcher, find_version =
    unpack(meta)
  local insert_text = item.label
  if item.insertText then
    insert_text = item.insertText
  end
  local line_last_char = line:sub(#line)
  local pos_end_line = line_last_char == "," and (#line - 1) or #line
  if find_version then
    replace_text(ctx, insert_text, pos_third_quote, pos_fourth_quote, pos_end_line)
  else
    local pos_first_quote = pos_start_name - 1
    replace_text(ctx, insert_text, pos_first_quote, pos_second_quote, pos_end_line)
  end
  callback()
end

return source
