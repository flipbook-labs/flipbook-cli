local json = require("@std/json")
local net = require("@std/net")

type HttpMethod = "GET" | "POST" | "PATCH"

type FetchOptions = {
	method: HttpMethod?,
	headers: { [string]: string }?,
	body: string?,
}

local function fetch(url: string, options: FetchOptions)
	local method: HttpMethod = options.method or "GET"

	local res = net.request(url, {
		method = method,
		headers = options.headers,
		body = options.body,
	})

	local parseOk, bodyAsJson = pcall(json.deserialize, res.body)

	if res.ok then
		if parseOk and bodyAsJson ~= nil then
			return bodyAsJson
		else
			return res.body
		end
	else
		local problems: { string } = {}

		if parseOk then
			local body = json.asObject(bodyAsJson)
			if body then
				if body.errors then
					for _, err in body.errors do
						table.insert(problems, err.message :: string)
					end
				elseif body.message then
					table.insert(problems, body.message :: string)
				end
			end
		end

		error(
			`{res.status} {res.body} when attempting to {method} {url}`
				.. if #problems > 0 then `: {table.concat(problems, ", ")}` else "",
			2
		)
	end
end

return fetch
