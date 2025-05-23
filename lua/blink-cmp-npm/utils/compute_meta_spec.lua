local compute_meta = require("blink-cmp-npm.utils.compute_meta")

describe("compute_meta", function()
  it("should compute cursor metadata", function()
    local meta = compute_meta('  "name": "1.0.0",', { cursor = { 1, 4 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(17, pos_fourth_quote)
    assert.are.equal(nil, current_version)
    assert.are.equal(nil, current_version_matcher)
    assert.is_false(find_version)
  end)

  it("should handle missing 2nd quote", function()
    local meta = compute_meta('  "name', { cursor = { 1, 4 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(nil, pos_second_quote)
    assert.are.equal(nil, pos_third_quote)
    assert.are.equal(nil, pos_fourth_quote)
    assert.are.equal(nil, current_version)
    assert.are.equal(nil, current_version_matcher)
    assert.is_false(find_version)
  end)

  it("should handle missing 3rd quote", function()
    local meta = compute_meta('  "name":', { cursor = { 1, 10 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(nil, pos_third_quote)
    assert.are.equal(nil, pos_fourth_quote)
    assert.are.equal(nil, current_version)
    assert.are.equal(nil, current_version_matcher)
    assert.is_false(find_version)
  end)

  it("should handle missing 4th quote", function()
    local meta = compute_meta('  "name": "', { cursor = { 1, 12 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(nil, pos_fourth_quote)
    assert.are.equal("", current_version)
    assert.are.equal("", current_version_matcher)
    assert.is_true(find_version)
  end)

  it("should handle 4th quote but no version", function()
    local meta = compute_meta('  "name": ""', { cursor = { 1, 12 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(12, pos_fourth_quote)
    assert.are.equal("", current_version)
    assert.are.equal("", current_version_matcher)
    assert.is_true(find_version)
  end)

  it("should handle handle version matcher", function()
    local meta = compute_meta('  "name": "~1.0.0"', { cursor = { 1, 12 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(18, pos_fourth_quote)
    assert.are.equal("", current_version)
    assert.are.equal("~", current_version_matcher)
    assert.is_true(find_version)
  end)

  it("should return partial version depending on the cursor position", function()
    local meta = compute_meta('  "name": "~1.0.0"', { cursor = { 1, 15 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(18, pos_fourth_quote)
    assert.are.equal("1.0", current_version)
    assert.are.equal("~", current_version_matcher)
    assert.is_true(find_version)
  end)

  it("should return full version before the last quote", function()
    local meta = compute_meta('  "name": "~1.0.0"', { cursor = { 1, 17 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(18, pos_fourth_quote)
    assert.are.equal("1.0.0", current_version)
    assert.are.equal("~", current_version_matcher)
    assert.is_true(find_version)
  end)

  it("should return full version after the last quote", function()
    local meta = compute_meta('  "name": "~1.0.0"', { cursor = { 1, 18 } })
    local name, pos_start_name, pos_end_name, pos_second_quote, pos_third_quote, pos_fourth_quote, current_version, current_version_matcher, find_version =
      unpack(meta)
    assert.are.equal("name", name)
    assert.are.equal(4, pos_start_name)
    assert.are.equal(7, pos_end_name)
    assert.are.equal(8, pos_second_quote)
    assert.are.equal(11, pos_third_quote)
    assert.are.equal(18, pos_fourth_quote)
    assert.are.equal("1.0.0", current_version)
    assert.are.equal("~", current_version_matcher)
    assert.is_true(find_version)
  end)
end)
