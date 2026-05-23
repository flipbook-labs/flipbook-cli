return [[
local HttpService = game:GetService("HttpService")
local AssetService = game:GetService("AssetService")

local DESIRED_NAME = assert(_G.DESIRED_NAME, "DESIRED_NAME global is required")

local function findPlaceByName(name: string): number?
	local pages = AssetService:GetGamePlacesAsync()
	while true do
		for _, place in pages:GetCurrentPage() do
			if place.Name == name then
				return place.PlaceId
			end
		end
		if pages.IsFinished then
			break
		end
		pages:AdvanceToNextPageAsync()
	end
	return nil
end

local existingId = findPlaceByName(DESIRED_NAME)
if existingId then
	print(HttpService:JSONEncode({ placeId = existingId, created = false }))
	return
end

local placeId = AssetService:CreatePlaceAsync(
	DESIRED_NAME,
	game.PlaceId,
	"Flipbook storybook preview"
)

print(HttpService:JSONEncode({ placeId = placeId, created = true }))
]]
