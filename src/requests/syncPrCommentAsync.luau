local json = require("@std/json")

local fetch = require("@root/requests/fetch")
local githubHeaders = require("@root/requests/githubHeaders")

local PR_COMMENT_MARKER = "<!-- flipbook-pr-preview -->"

local function syncPrCommentAsync(
	repo: string,
	prNumber: number,
	githubToken: string,
	body: string
)
	local headers = githubHeaders(githubToken)
	headers["Content-Type"] = "application/json"

	local listRes = fetch(
		`https://api.github.com/repos/{repo}/issues/{prNumber}/comments?per_page=100`,
		{ headers = headers }
	)

	local comments = json.deserialize(listRes.body) :: any
	local existingId: number? = nil
	for _, c in comments do
		if (c.body :: string):find(PR_COMMENT_MARKER, 1, true) then
			existingId = c.id :: number
			break
		end
	end

	local payload = json.serialize({ body = body })
	if existingId then
		fetch(`https://api.github.com/repos/{repo}/issues/comments/{existingId}`, {
			method = "PATCH",
			headers = headers,
			body = payload,
		})
	else
		fetch(`https://api.github.com/repos/{repo}/issues/{prNumber}/comments`, {
			method = "POST",
			headers = headers,
			body = payload,
		})
	end
end

return syncPrCommentAsync
