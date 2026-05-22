local json = require("@std/json")
local net = require("@std/net")
local process = require("@std/process")

local loadStorybookConfig = require("@root/storybookConfig")
local resolvePlaceId = require("@root/resolvePlaceId")
local storybookPreviewUrl = require("@root/storybookPreviewUrl")

local PR_COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

export type CommentOptions = {
	prNumber: number,
	name: string?,
	githubToken: string,
	repo: string,
	universeId: string?,
	startPlaceId: string?,
}

local function comment(options: CommentOptions)
	local name = options.name or `pr-{options.prNumber}`
	local apiKey = assert(process.env.ROBLOX_API_KEY, "ROBLOX_API_KEY environment variable is required")
	local storybook = loadStorybookConfig({
		universeId = options.universeId,
		startPlaceId = options.startPlaceId,
	})
	local placeId = resolvePlaceId(name, storybook, apiKey)

	local timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local body = PR_COMMENT_MARKER
		.. "\n## Storybook Preview\n\n"
		.. "| | Link |\n|--|------|\n"
		.. "| Play | [Open in Roblox]("
		.. storybookPreviewUrl(placeId)
		.. ") |\n\n"
		.. "*Place `"
		.. name
		.. "` · "
		.. timestamp
		.. "*"

	local headers: { [string]: string } = {
		Authorization = "Bearer " .. options.githubToken,
		Accept = "application/vnd.github+json",
		["Content-Type"] = "application/json",
	}

	local listResponse = net.request(
		"https://api.github.com/repos/" .. options.repo .. "/issues/" .. options.prNumber .. "/comments?per_page=100",
		{ method = "GET", headers = headers }
	)
	local comments = json.deserialize(listResponse.body) :: any
	local existingId: number? = nil
	for _, c in comments do
		if (c.body :: string):find(PR_COMMENT_MARKER, 1, true) then
			existingId = c.id :: number
			break
		end
	end

	local payload = json.serialize({ body = body })
	if existingId then
		net.request(
			"https://api.github.com/repos/" .. options.repo .. "/issues/comments/" .. existingId,
			{ method = "PATCH", headers = headers, body = payload }
		)
	else
		net.request(
			"https://api.github.com/repos/" .. options.repo .. "/issues/" .. options.prNumber .. "/comments",
			{ method = "POST", headers = headers, body = payload }
		)
	end
end

return comment
