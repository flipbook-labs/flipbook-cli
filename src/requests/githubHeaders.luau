local process = require("@std/process")

local function githubHeaders(githubToken: string?): { [string]: string }
	local headers: { [string]: string } = {
		Accept = "application/vnd.github+json",
		["User-Agent"] = "flipbook-cli",
	}

	local token = githubToken or process.env.GITHUB_TOKEN
	if token then
		headers.Authorization = `Bearer {token}`
	end

	return headers
end

return githubHeaders
