local json = require("@std/json")
local net = require("@std/net")

export type HttpMethod = "GET" | "POST" | "PATCH" | "DELETE"

export type GithubRequestOptions = {
	token: string,
	method: HttpMethod?,
	headers: { [string]: string }?,
	body: string?,
}

local function githubRequest(url: string, options: GithubRequestOptions): any
	local headers: { [string]: string } = {
		Authorization = `Bearer {options.token}`,
		Accept = "application/vnd.github+json",
		["User-Agent"] = "flipbook-cli",
		["X-GitHub-Api-Version"] = "2022-11-28",
	}
	if options.body then
		headers["Content-Type"] = "application/json"
	end
	if options.headers then
		for key, value in options.headers do
			headers[key] = value
		end
	end

	local method: HttpMethod = options.method or "GET"
	local res = net.request(url, { method = method, headers = headers, body = options.body })

	if not res.ok then
		local message = res.body
		local parseOk, parsed = pcall(json.deserialize, res.body)
		if parseOk then
			local body = json.asObject(parsed)
			if body and type(body.message) == "string" then
				message = body.message :: string
			end
		end
		error(`GitHub API request failed ({res.status}) for {method} {url}: {message}`, 0)
	end

	if res.body == "" then
		return nil
	end
	local parseOk, parsed = pcall(json.deserialize, res.body)
	return if parseOk then parsed else res.body
end

return githubRequest
