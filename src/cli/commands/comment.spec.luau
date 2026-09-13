local cli = require("@batteries/cli")
local test = require("@std/test")

local comment = require("@root/cli/commands/comment")
local helpText = require("@root/cli/helpText")

test.suite("comment", function(suite)
	suite:case("documents the optional preview inputs", function(assert)
		local parser = comment.parser
		assert.that(parser ~= nil)
		local output = helpText.build(parser :: cli.Parser, {
			title = comment.title,
			summary = comment.summary,
		})

		assert.strContains(output, "--launch-data <launch-data>")
		assert.strContains(output, "--current-place-name <current-place-name>")
	end)
end)
