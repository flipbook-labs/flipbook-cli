local json = require("@std/json")

local storybookPreviewComment = require("@root/storybookPreviewComment")

type PublishedFrom = storybookPreviewComment.PublishedFrom

-- Matches `process.env`, where a missing variable reads as nil.
export type Env = { [string]: string }

-- Reads the pull request's head commit from the event that started the
-- workflow. That commit is the one the workflow checked out and deployed, even
-- if someone pushes again while it runs.
local function getEventHeadSha(eventJson: string): string?
	local ok, parsed = pcall(json.deserialize, eventJson)
	if not ok or type(parsed) ~= "table" then
		return nil
	end
	local pullRequest = (parsed :: any).pull_request
	local head: any = if type(pullRequest) == "table" then pullRequest.head else nil
	local sha = if type(head) == "table" then head.sha else nil
	return if type(sha) == "string" then sha else nil
end

-- Names the commit and workflow run a preview came from, using what GitHub
-- Actions provides. Outside a pull request event it falls back to GITHUB_SHA,
-- and outside Actions there is no footer.
local function getPublishedFrom(repo: string, env: Env, readFile: (path: string) -> string?): PublishedFrom?
	local eventPath: string? = env.GITHUB_EVENT_PATH
	local eventJson = if eventPath then readFile(eventPath) else nil
	local sha = (if eventJson then getEventHeadSha(eventJson) else nil) or env.GITHUB_SHA
	if not sha then
		return nil
	end

	local runUrl = if env.GITHUB_SERVER_URL and env.GITHUB_RUN_ID
		then `{env.GITHUB_SERVER_URL}/{repo}/actions/runs/{env.GITHUB_RUN_ID}`
		else nil
	return {
		sha = sha,
		runNumber = env.GITHUB_RUN_NUMBER,
		runUrl = runUrl,
	}
end

return getPublishedFrom
