return [[
local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")

local DESIRED_NAME = assert(_G.DESIRED_NAME, "DESIRED_NAME global is required")

local placeId = AssetService:CreatePlaceAsync(
	DESIRED_NAME,
	game.PlaceId,
	"Flipbook storybook preview"
)

print(HttpService:JSONEncode({ placeId = placeId }))
]]
