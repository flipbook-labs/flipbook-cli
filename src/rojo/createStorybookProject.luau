local path = require("@std/path")

local types = require("@root/rojo/types")

-- Rojo mounts a model file's one top-level instance, so everything the stories
-- require has to be inside it with them.
local function createStorybookProject(options: {
	name: string,
	storiesPath: path.Pathlike,
	flipbookRbxmPath: path.Pathlike,
}): types.RojoProjectContent
	return {
		name = options.name,
		emitLegacyScripts = false,
		tree = {
			["$className"] = "DataModel",
			ReplicatedStorage = {
				Flipbook = {
					["$path"] = tostring(path.resolve(options.flipbookRbxmPath)),
				},
				Stories = {
					["$path"] = tostring(path.resolve(options.storiesPath)),
				},
			},
		},
	}
end

return createStorybookProject
