local fs = require("@std/fs")
local path = require("@std/path")
local test = require("@std/test")

local buttonFiles = require("@root/buttonFiles")
local getTempDir = require("@root/getTempDir")

local FILES = {
	{ name = "join-light.svg", contents = "<svg>light</svg>" },
	{ name = "join-dark.svg", contents = "<svg>dark</svg>" },
}

local function freshDir(name: string): path.Path
	local dir = path.join(getTempDir(), `buttonFiles-{name}`)
	if fs.exists(dir) then
		fs.removeDirectory(dir, { recursive = true })
	end
	return dir
end

test.suite("buttonFiles", function(suite)
	suite:case("finds every file stale in a folder that doesn't exist", function(assert)
		local dir = freshDir("missing")

		assert.eq(#buttonFiles.findStale(dir, FILES), 2)
		assert.eq(fs.exists(dir), false)
	end)

	suite:case("finds nothing stale after writing the files", function(assert)
		local dir = freshDir("written")
		buttonFiles.write(dir, FILES)

		assert.eq(fs.readFileToString(path.join(dir, "join-dark.svg")), "<svg>dark</svg>")
		assert.eq(#buttonFiles.findStale(dir, FILES), 0)
	end)

	suite:case("finds a changed file and a deleted file without rewriting them", function(assert)
		local dir = freshDir("changed")
		buttonFiles.write(dir, FILES)
		fs.writeStringToFile(path.join(dir, "join-light.svg"), "<svg>edited</svg>")
		fs.remove(path.join(dir, "join-dark.svg"))

		local stale = buttonFiles.findStale(dir, FILES)

		assert.eq(#stale, 2)
		assert.eq(stale[1].name, "join-light.svg")
		assert.eq(stale[2].name, "join-dark.svg")
		assert.eq(fs.readFileToString(path.join(dir, "join-light.svg")), "<svg>edited</svg>")
		assert.eq(fs.exists(path.join(dir, "join-dark.svg")), false)
	end)
end)
