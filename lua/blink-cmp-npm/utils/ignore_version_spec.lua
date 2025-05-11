local ignore_version = require("blink-cmp-npm.utils.ignore_version")

describe("ignore_version", function()
  it("should ignore non-semantic versions", function()
    assert.is_true(ignore_version("1.0.0-beta", "", { only_semantic_versions = true }))
  end)

  it("should ignore versions containing ignored keywords", function()
    assert.is_true(ignore_version("1.0.0-beta", "", { ignore = { "beta" } }))
  end)

  it('should include versions that start with "current_version"', function()
    assert.is_false(ignore_version("1.0.0", "1.0", {}))
  end)

  it('should ignore versions that do not start with "current_version"', function()
    assert.is_true(ignore_version("1.0.0", "1.1", {}))
  end)
end)
