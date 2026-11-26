local cli = require("@lpm/batteries@v1.0.1-nightly.20261115/cli")
local json = require("@std/json")
local process = require("@std/process")

local buttonAssets = require("@root/buttonAssets")
local getPlaceIdByNameAsync = require("@root/requests/getPlaceIdByNameAsync")
local getUniverseThumbnailAsync = require("@root/requests/getUniverseThumbnailAsync")
local githubRequest = require("@root/requests/githubRequest")
local previewButtons = require("@root/previewButtons")
local storybookPreviewComment = require("@root/storybookPreviewComment")
local types = require("@root/cli/types")

local PR_COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local title = "comment"
local summary = "Post or update the storybook preview comment on a pull request."

local parser = cli.parser()

parser:add("pr", "option", {
	help = "Pull request number to comment on.",
	required = true,
})
parser:add("universe-id", "option", {
	help = "Universe the preview place lives in.",
	required = true,
})
parser:add("place-name", "option", {
	help = "Name of the deployed preview place. Resolved to a place ID to build the link.",
	required = true,
})
parser:add("launch-data", "option", {
	help = "JSON object to include as launch data in the preview link.",
})
parser:add("comment-template", "option", {
	help = "Optional Markdown template for the preview comment.",
})
parser:add("assets-dir", "option", {
	help = `Folder in the repository that holds the buttons from \`flipbook-cli generate\`. Defaults to {previewButtons.DEFAULT_ASSETS_DIR}.`,
})
parser:add("api-key", "option", {
	help = "Roblox API key (Can also be supplied by the ROBLOX_API_KEY env var)",
})
parser:add("github-token", "option", {
	help = "GitHub token (Can also be supplied by the GITHUB_TOKEN env var)",
})
parser:add("github-repository", "option", {
	help = "owner/repo (Can also be supplied by the GITHUB_REPOSITORY env var)",
})
parser:add("help", "flag", {
	help = "Show this help message",
})

-- Looks up the button images on the default branch. When the comment can't
-- show them, it says why in the log and the comment falls back to text links.
local function findButtonsBaseUrlAsync(repo: string, assetsDir: string, githubToken: string): string?
	local info = githubRequest(`https://api.github.com/repos/{repo}`, { token = githubToken })
	local repository: buttonAssets.Repository = {
		name = repo,
		defaultBranch = info.default_branch :: string,
		private = info.private == true,
	}

	local availableFiles: { string } = {}
	if not repository.private then
		local dir = buttonAssets.encodePath(buttonAssets.normalizeDir(assetsDir))
		local ref = buttonAssets.encodePath(repository.defaultBranch)
		local ok, entries = pcall(function()
			return githubRequest(
				`https://api.github.com/repos/{repo}/contents/{dir}?ref={ref}`,
				{ token = githubToken }
			)
		end)
		if ok and type(entries) == "table" then
			for _, entry in entries :: { any } do
				if type(entry.name) == "string" then
					table.insert(availableFiles, entry.name)
				end
			end
		end
	end

	local baseUrl, reason = buttonAssets.findBaseUrl(repository, assetsDir, availableFiles)
	if not baseUrl then
		print(`Showing text links instead of buttons because {reason}.`)
	end
	return baseUrl
end

-- Names the commit and workflow run the preview came from. Actions sets the run
-- variables; elsewhere the footer names only the commit.
local function getPublishedFrom(
	repo: string,
	prNumber: number,
	githubToken: string
): storybookPreviewComment.PublishedFrom
	local pull = githubRequest(`https://api.github.com/repos/{repo}/pulls/{prNumber}`, { token = githubToken })
	local env = process.env
	local runUrl = if env.GITHUB_SERVER_URL and env.GITHUB_RUN_ID
		then `{env.GITHUB_SERVER_URL}/{repo}/actions/runs/{env.GITHUB_RUN_ID}`
		else nil
	return {
		sha = pull.head.sha :: string,
		runNumber = env.GITHUB_RUN_NUMBER,
		runUrl = runUrl,
	}
end

local function run()
	local prNumber = assert(tonumber(parser:get("pr")), "--pr must be a number")
	local universeId = assert(tonumber(parser:get("universe-id")), "--universe-id must be a number")
	local placeName = parser:get("place-name") :: string
	local launchData = parser:get("launch-data")
	local commentTemplate = parser:get("comment-template")
	local assetsDir = parser:get("assets-dir") or previewButtons.DEFAULT_ASSETS_DIR
	local apiKey = assert(
		parser:get("api-key") or process.env.ROBLOX_API_KEY,
		"An Open Cloud API key is required, use --api-key or the ROBLOX_API_KEY env var to supply it"
	)
	local githubToken = assert(
		parser:get("github-token") or process.env.GITHUB_TOKEN,
		"A GitHub token is required, use --github-token or the GITHUB_TOKEN env var to supply it"
	)
	local repo = assert(
		parser:get("github-repository") or process.env.GITHUB_REPOSITORY,
		"A GitHub repository (owner/repo) is required, use --github-repository or the GITHUB_REPOSITORY env var"
	)

	local targetPlaceId = assert(
		getPlaceIdByNameAsync(universeId, placeName, apiKey),
		`Could not find a place named "{placeName}" in universe {universeId}`
	)

	local body = `{PR_COMMENT_MARKER}\n{storybookPreviewComment({
		buttonsBaseUrl = if commentTemplate then nil else findButtonsBaseUrlAsync(repo, assetsDir, githubToken),
		placeId = targetPlaceId,
		launchData = launchData,
		publishedFrom = getPublishedFrom(repo, prNumber, githubToken),
		template = commentTemplate,
		thumbnailUrl = getUniverseThumbnailAsync(universeId),
	})}`

	local existingId: number? = nil
	local page = 1
	while not existingId do
		local comments = githubRequest(
			`https://api.github.com/repos/{repo}/issues/{prNumber}/comments?per_page=100&page={page}`,
			{ token = githubToken }
		) :: { any }
		if type(comments) ~= "table" then
			break
		end
		for _, comment in comments do
			if type(comment.body) == "string" and (comment.body :: string):find(PR_COMMENT_MARKER, 1, true) then
				existingId = comment.id :: number
				break
			end
		end
		if #comments < 100 then
			break
		end
		page += 1
	end

	local payload = json.serialize({ body = body })
	if existingId then
		githubRequest(`https://api.github.com/repos/{repo}/issues/comments/{existingId}`, {
			token = githubToken,
			method = "PATCH",
			body = payload,
		})
		print(`Updated storybook preview comment on PR #{prNumber} (comment {existingId}).`)
	else
		githubRequest(`https://api.github.com/repos/{repo}/issues/{prNumber}/comments`, {
			token = githubToken,
			method = "POST",
			body = payload,
		})
		print(`Posted storybook preview comment on PR #{prNumber}.`)
	end
end

local command: types.Command = {
	run = run,
	title = title,
	summary = summary,
	parser = parser,
}

return command
