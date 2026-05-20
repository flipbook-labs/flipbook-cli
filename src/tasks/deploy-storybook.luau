return [[
local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PR_NUMBER = assert(tonumber(_G.PR_NUMBER), "PR_NUMBER global is required")
local STORYBOOK_ASSET_ID = assert(tonumber(_G.STORYBOOK_ASSET_ID), "STORYBOOK_ASSET_ID global is required")

local prStorybooks = ReplicatedStorage:FindFirstChild("PRStorybooks")
if not prStorybooks then
	prStorybooks = Instance.new("Folder")
	prStorybooks.Name = "PRStorybooks"
	prStorybooks.Parent = ReplicatedStorage
end

local existing = prStorybooks:FindFirstChild("pr-" .. PR_NUMBER)
if existing then
	existing:Destroy()
end

local model = assert(AssetService:LoadAssetAsync(STORYBOOK_ASSET_ID), "failed to load storybook asset")
model.Name = "pr-" .. PR_NUMBER
model.Parent = prStorybooks

AssetService:SavePlaceAsync()
]]
