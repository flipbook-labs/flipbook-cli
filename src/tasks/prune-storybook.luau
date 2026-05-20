return [[
local PR_NUMBER = assert(tonumber(_G.PR_NUMBER), "PR_NUMBER global is required")

local AssetService = game:GetService("AssetService")
local rs = game:GetService("ReplicatedStorage")

local prStorybooks = rs:FindFirstChild("PRStorybooks")
if prStorybooks then
	local existing = prStorybooks:FindFirstChild("pr-" .. PR_NUMBER)
	if existing then
		existing:Destroy()
	end
end

AssetService:SavePlaceAsync()
]]
