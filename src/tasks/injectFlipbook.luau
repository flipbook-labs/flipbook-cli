return [[
local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ASSET_ID = _G.ASSET_ID
assert(ASSET_ID, "_G.ASSET_ID must be supplied")

local assetId = assert(tonumber(ASSET_ID), "_G.ASSET_ID must be a valid number")

local model = InsertService:LoadAsset(assetId)

-- LoadAsset wraps content in a Model. Pull out the actual Flipbook folder
-- and parent it directly under ReplicatedStorage so scripts that do
-- require(script.Parent.workspace.flipbook-core) resolve correctly.
local flipbook = model:GetChildren()[1]
assert(flipbook, "LoadAsset returned an empty model for asset " .. tostring(assetId))
flipbook.Name = "Flipbook"
flipbook.Parent = ReplicatedStorage
model:Destroy()

AssetService:SavePlaceAsync()

print(HttpService:JSONEncode({ success = true, assetId = assetId }))
]]
