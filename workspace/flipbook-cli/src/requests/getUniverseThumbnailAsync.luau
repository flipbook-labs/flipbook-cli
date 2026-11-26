local net = require("@std/net")

local getUniverseThumbnail = require("@root/getUniverseThumbnail")

local function getUniverseThumbnailAsync(universeId: number): string?
	local requestOk, response = pcall(function()
		return net.request(
			`https://thumbnails.roblox.com/v1/games/multiget/thumbnails?universeIds={universeId}&countPerUniverse=1&defaults=true&size=768x432&format=Png&isCircular=false`
		)
	end)
	if not requestOk or not response.ok then
		return nil
	end

	return getUniverseThumbnail(response.body)
end

return getUniverseThumbnailAsync
