local fetch = require("@root/requests/fetch")

-- Upload the raw bytes to the signed URL from createBinaryInputAsync. No API key is
-- sent here; authorization is baked into the URL.
local function uploadBinaryFileAsync(uploadUri: string, contents: string)
	fetch(uploadUri, {
		method = "PUT",
		headers = {
			["content-type"] = "application/octet-stream",
		},
		body = contents,
	})
end

return uploadBinaryFileAsync
