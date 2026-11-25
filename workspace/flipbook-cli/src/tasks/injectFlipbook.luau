return [[
local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SerializationService = game:GetService("SerializationService")

-- The Flipbook rbxm is uploaded as the task's binary input and handed to the
-- script as the first argument. DeserializeInstancesAsync is only available in
-- Studio plugins and Open Cloud Luau Execution sessions, which is exactly here.
local arg = ({ ... })[1]
assert(arg and arg.BinaryInput, "task was not supplied a binary input")

local instances = SerializationService:DeserializeInstancesAsync(arg.BinaryInput)
local flipbook = instances[1]
assert(flipbook, "binary input deserialized to zero instances")

-- Parent the Flipbook folder directly under ReplicatedStorage so scripts that
-- do require(ReplicatedStorage.Flipbook...) resolve correctly. Replace any
-- existing copy so re-deploys stay idempotent.
local existing = ReplicatedStorage:FindFirstChild("Flipbook")
if existing then
	existing:Destroy()
end

flipbook.Name = "Flipbook"
flipbook.Parent = ReplicatedStorage

AssetService:SavePlaceAsync()

print(HttpService:JSONEncode({ success = true }))
]]
