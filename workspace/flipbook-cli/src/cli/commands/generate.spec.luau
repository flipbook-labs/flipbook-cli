local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local test = require("@std/test")

local generate = require("@root/cli/commands/generate")
local helpText = require("@root/cli/helpText")

test.suite("generate", function(suite)
	suite:case("documents the assets folder and check options", function(assert)
		local parser = generate.parser
		assert.that(parser ~= nil)
		local output = helpText.build(parser :: cli.Parser, {
			title = generate.title,
			summary = generate.summary,
		})

		assert.strContains(output, "--assets-dir <assets-dir>")
		assert.strContains(output, ".github/deploy-storybook/assets")
		assert.strContains(output, "--check")
	end)
end)
