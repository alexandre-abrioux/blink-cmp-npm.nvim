local generate_doc = require("blink-cmp-npm.utils.generate_doc")

describe("generate_doc", function()
  it("should generate package doc", function()
    local doc = generate_doc({
      name = "react",
      keywords = { "react" },
      version = "19.1.0",
      description = "React is a JavaScript library for building user interfaces.",
      license = "MIT",
      date = "2025-03-28T19:59:42.053Z",
      links = { homepage = "https://react.dev/", npm = "https://www.npmjs.com/package/react" },
    })
    assert.are.equal(
      "# `react`\n\n"
        .. "https://www.npmjs.com/package/react\n"
        .. "https://react.dev/\n\n"
        .. "## Latest\n"
        .. "19.1.0 (2025-03-28)\n\n"
        .. "## About\n"
        .. "React is a JavaScript library for building user interfaces.\n\n"
        .. "## License\n"
        .. "MIT\n\n"
        .. "## Keywords\n"
        .. "react",
      doc
    )
  end)
end)
