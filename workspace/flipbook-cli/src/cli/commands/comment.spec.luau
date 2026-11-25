local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local test = require("@std/test")

local comment = require("@root/cli/commands/comment")
local helpText = require("@root/cli/helpText")

test.suite("comment", function(suite)
	suite:case("documents the launch data option", function(assert)
		local parser = comment.parser
		assert.that(parser ~= nil)
		local output = helpText.build(parser :: cli.Parser, {
			title = comment.title,
			summary = comment.summary,
		})

		assert.strContains(output, "--launch-data <launch-data>")
	end)
end)
