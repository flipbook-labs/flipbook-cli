local SvgButtons = require("@workspace/svg-buttons")

local percentEncode = require("@root/percentEncode")
local previewButtons = require("@root/previewButtons")

export type Repository = {
	-- `owner/repo`.
	name: string,
	defaultBranch: string,
	private: boolean,
}

local function encodePath(value: string): string
	local segments: { string } = {}
	for segment in string.gmatch(value, "[^/]+") do
		table.insert(segments, percentEncode(segment))
	end
	return table.concat(segments, "/")
end

-- Trims `./` and slashes so `assetsDir` joins cleanly into a URL.
local function normalizeDir(assetsDir: string): string
	local normalized = string.gsub(assetsDir, "^%./", "")
	normalized = string.gsub(normalized, "^/+", "")
	normalized = string.gsub(normalized, "/+$", "")
	return normalized
end

local function getExpectedFiles(): { string }
	local files: { string } = {}
	for _, button in previewButtons.BUTTONS do
		local names = SvgButtons.buttonFileNames(button.name)
		table.insert(files, names.light)
		table.insert(files, names.dark)
		table.insert(files, names.fallback)
	end
	return files
end

-- Decides whether the comment can show the button images, given the files
-- found in `assetsDir` on the default branch. GitHub fetches comment images
-- anonymously, so they only load from public repositories. Returns the folder's
-- raw.githubusercontent.com URL, or nil and the reason the comment falls back
-- to text links.
local function findBaseUrl(repository: Repository, assetsDir: string, availableFiles: { string }): (string?, string?)
	local dir = normalizeDir(assetsDir)

	if repository.private then
		return nil, "the repository is private, and GitHub only shows comment images from public repositories"
	end

	local available: { [string]: boolean } = {}
	for _, file in availableFiles do
		available[file] = true
	end

	local missing: { string } = {}
	for _, file in getExpectedFiles() do
		if not available[file] then
			table.insert(missing, file)
		end
	end
	if #missing > 0 then
		return nil, `{dir} on {repository.defaultBranch} is missing {table.concat(missing, ", ")}`
	end

	return `https://raw.githubusercontent.com/{repository.name}/{encodePath(repository.defaultBranch)}/{encodePath(dir)}`,
		nil
end

return table.freeze({
	encodePath = encodePath,
	findBaseUrl = findBaseUrl,
	getExpectedFiles = getExpectedFiles,
	normalizeDir = normalizeDir,
})
