local fs = require("@std/fs")
local path = require("@std/path")

local SvgButtons = require("@workspace/svg-buttons")

type ButtonFile = SvgButtons.ButtonFile

-- The files that are missing from `dir` or differ from what's expected there.
local function findStale(dir: path.Pathlike, files: { ButtonFile }): { ButtonFile }
	local stale = {}
	for _, file in files do
		local target = path.join(dir, file.name)
		if not fs.exists(target) or fs.readFileToString(target) ~= file.contents then
			table.insert(stale, file)
		end
	end
	return stale
end

-- Writes the files to `dir`, creating it when needed.
local function write(dir: path.Pathlike, files: { ButtonFile })
	if not fs.exists(dir) then
		fs.createDirectory(dir, { makeParents = true })
	end
	for _, file in files do
		fs.writeStringToFile(path.join(dir, file.name), file.contents)
	end
end

return {
	findStale = findStale,
	write = write,
}
