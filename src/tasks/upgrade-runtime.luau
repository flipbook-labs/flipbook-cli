return [[
local RUNTIME_ASSET_ID = assert(tonumber(_G.RUNTIME_ASSET_ID), "RUNTIME_ASSET_ID global is required")

local AssetService = game:GetService("AssetService")
local rs = game:GetService("ReplicatedStorage")

local oldRuntime = rs:FindFirstChild("Flipbook")
if oldRuntime then
	oldRuntime:Destroy()
end

local runtime = assert(AssetService:LoadAssetAsync(RUNTIME_ASSET_ID), "failed to load runtime asset")
runtime.Name = "Flipbook"
runtime.Parent = rs

AssetService:SavePlaceAsync()
]]
