local test = require("@std/test")

local getPublishedFrom = require("@root/getPublishedFrom")

local EVENT = '{"pull_request":{"head":{"sha":"headsha123"}}}'

local function readEvent(path: string): string?
	return if path == "/event.json" then EVENT else nil
end

test.suite("getPublishedFrom", function(suite)
	suite:case("names the pull request head from the triggering event", function(assert)
		local publishedFrom = getPublishedFrom("owner/repo", {
			GITHUB_EVENT_PATH = "/event.json",
			GITHUB_SHA = "mergesha456",
			GITHUB_SERVER_URL = "https://github.com",
			GITHUB_RUN_ID = "9",
			GITHUB_RUN_NUMBER = "42",
		}, readEvent)

		assert.eq(publishedFrom and publishedFrom.sha, "headsha123")
		assert.eq(publishedFrom and publishedFrom.runNumber, "42")
		assert.eq(publishedFrom and publishedFrom.runUrl, "https://github.com/owner/repo/actions/runs/9")
	end)

	suite:case("falls back to GITHUB_SHA outside pull request events", function(assert)
		local publishedFrom = getPublishedFrom("owner/repo", { GITHUB_SHA = "pushsha789" }, readEvent)

		assert.eq(publishedFrom and publishedFrom.sha, "pushsha789")
		assert.eq(publishedFrom and publishedFrom.runUrl, nil)
	end)

	suite:case("leaves out the footer outside Actions", function(assert)
		assert.eq(getPublishedFrom("owner/repo", {}, readEvent), nil)
	end)
end)
