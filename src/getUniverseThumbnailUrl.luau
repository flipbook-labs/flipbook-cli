local json = require("@std/json")

local function getUniverseThumbnailUrl(responseBody: string): string?
	local body = json.asObject(json.deserialize(responseBody))
	local games = if body then json.asArray(body.data) else nil
	local game = if games and games[1] then json.asObject(games[1]) else nil
	local thumbnails = if game then json.asArray(game.thumbnails) else nil
	local thumbnail = if thumbnails and thumbnails[1] then json.asObject(thumbnails[1]) else nil

	if thumbnail and thumbnail.state == "Completed" and type(thumbnail.imageUrl) == "string" then
		return thumbnail.imageUrl :: string
	end

	return nil
end

return getUniverseThumbnailUrl
