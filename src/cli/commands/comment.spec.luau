local cli = require("@batteries/cli")
local test = require("@std/test")

local comment = require("@root/cli/commands/comment")

test.suite("comment", function(suite)
	suite:case("documents the launch data option", function(assert)
		local parser = cli.parser()
		comment.configure(parser)

		assert.strContains(parser:help(), "--launch-data - JSON object to include as launch data")
	end)
end)
