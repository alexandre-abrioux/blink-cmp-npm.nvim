---@param version string
---@param opts blink-cmp-npm.Options
---@return boolean
local function ignore_version(version, current_version, opts)
  if opts.only_semantic_versions and not string.match(version, "^%d+%.%d+%.%d+$") then
    return true
  end
  if opts.ignore then
    for _, ignoreString in ipairs(opts.ignore) do
      if string.match(version, ignoreString) then
        return true
      end
    end
  end
  if current_version and #current_version > 0 and version:sub(1, #current_version) ~= current_version then
    return true
  end
  return false
end

return ignore_version
