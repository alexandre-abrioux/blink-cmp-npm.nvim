local semantic_sort = require("blink-cmp-npm.utils.semantic_sort")

describe("semantic_sort", function()
  it("should compare major versions", function()
    assert.is_true(semantic_sort({ label = "2.0.0" }, { label = "1.0.0" }))
  end)

  it("should compare minor versions", function()
    assert.is_true(semantic_sort({ label = "1.1.0" }, { label = "1.0.0" }))
  end)

  it("should compare patch versions", function()
    assert.is_true(semantic_sort({ label = "1.0.1" }, { label = "1.0.0" }))
  end)
end)
