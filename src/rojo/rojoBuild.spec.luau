local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")
local test = require("@std/test")

local createStorybookProject = require("@root/rojo/createStorybookProject")
local rojoBuild = require("@root/rojo/rojoBuild")

local STORIES_MODEL = [[
<roblox version="4">
	<Item class="Folder">
		<Properties><string name="Name">MyStories</string></Properties>
		<Item class="ModuleScript">
			<Properties>
				<string name="Name">Button.story</string>
				<string name="Source">return "button story"</string>
			</Properties>
		</Item>
		<Item class="Folder">
			<Properties><string name="Name">Packages</string></Properties>
		</Item>
	</Item>
</roblox>
]]

local FLIPBOOK_MODEL = [[
<roblox version="4">
	<Item class="Folder">
		<Properties><string name="Name">Anything</string></Properties>
		<Item class="Script">
			<Properties>
				<string name="Name">Starter</string>
				<token name="RunContext">2</token>
			</Properties>
		</Item>
	</Item>
</roblox>
]]

-- Returns the text of the named instance, up to where its <Item> closes.
local function getItem(place: string, name: string): string
	local start = place:find(`<string name="Name">{name}</string>`, 1, true)
	assert(start, `{name} isn't in the place`)

	local depth = 1
	for position, closing in place:sub(start):gmatch("()<(/?)Item") do
		depth += if closing == "/" then -1 else 1
		if depth == 0 then
			return place:sub(start, start + (tonumber(position) :: number) - 2)
		end
	end
	error(`{name} never closes`)
end

test.suite("rojoBuild", function(suite)
	local dir = path.join(system.tmpdir(), "flipbook cli rojoBuild spec")
	local storiesPath = path.join(dir, "stories.rbxmx")
	local flipbookPath = path.join(dir, "flipbook.rbxmx")
	local outputPath = path.join(dir, "place.rbxlx")

	suite:beforeEach(function()
		fs.createDirectory(dir, { makeParents = true })
		fs.writeStringToFile(storiesPath, STORIES_MODEL)
		fs.writeStringToFile(flipbookPath, FLIPBOOK_MODEL)
	end)

	suite:afterEach(function()
		fs.removeDirectory(dir, { recursive = true })
	end)

	local function build(): string
		rojoBuild({
			output = outputPath,
			project = createStorybookProject({
				name = "Storybook Preview",
				storiesPath = storiesPath,
				flipbookRbxmPath = flipbookPath,
			}),
		})
		return fs.readFileToString(outputPath)
	end

	suite:case("mounts the stories and their packages under ReplicatedStorage.Stories", function(assert)
		local place = build()
		local storage = place:match('<Item class="ReplicatedStorage".*')
		assert.that(storage ~= nil)

		local stories = getItem(storage :: string, "Stories")
		assert.strContains(stories, '<string name="Name">Packages</string>')
		assert.strContains(stories, 'return "button story"')
	end)

	suite:case("names the Flipbook model Flipbook whatever it is called in its file", function(assert)
		local place = build()
		assert.strContains(place, '<string name="Name">Flipbook</string>')
		assert.that(place:find("Anything", 1, true) == nil)
		assert.strContains(place, '<string name="Name">Starter</string>')
	end)

	suite:case("keeps a script's run context", function(assert)
		assert.strContains(build(), '<token name="RunContext">2</token>')
	end)

	suite:case("reports why Rojo can't build a project", function(assert)
		fs.remove(storiesPath)
		local ok, err = pcall(build)
		assert.that(not ok)
		assert.strContains(tostring(err), "Rojo could not build")
	end)
end)
