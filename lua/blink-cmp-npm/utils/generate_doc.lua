---@param npm_item NpmPackage
---@return string
local function generate_doc(npm_item)
  return "# `"
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
    .. table.concat(npm_item.keywords, " ")
end

return generate_doc
