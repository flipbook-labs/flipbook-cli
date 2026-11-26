local test = require("@std/test")

local parseTaskPath = require("./parseTaskPath")

test.suite("parseTaskPath", function(suite)
	suite:case("splits a task path into its IDs", function(assert)
		local ids = parseTaskPath("universes/1/places/2/versions/3/luau-execution-sessions/abc-4/tasks/def-5")

		assert.eq(ids.universe_id, "1")
		assert.eq(ids.place_id, "2")
		assert.eq(ids.version_id, "3")
		assert.eq(ids.luau_execution_session_id, "abc-4")
		assert.eq(ids.task_id, "def-5")
	end)

	suite:case("rejects a path without a place version", function(assert)
		local ok, err = pcall(parseTaskPath, "universes/1/places/2/luau-execution-sessions/4/tasks/5")

		assert.eq(ok, false)
		assert.eq(err, "Unexpected Luau execution task path: universes/1/places/2/luau-execution-sessions/4/tasks/5")
	end)
end)
