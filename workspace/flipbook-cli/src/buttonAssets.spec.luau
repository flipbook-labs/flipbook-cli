local test = require("@std/test")

local buttonAssets = require("@root/buttonAssets")

local PUBLIC: buttonAssets.Repository = { name = "owner/repo", defaultBranch = "main", private = false }

test.suite("buttonAssets", function(suite)
	suite:case("links to the folder on the default branch when every button is there", function(assert)
		local url, reason = buttonAssets.findBaseUrl(PUBLIC, "./.github/assets/", buttonAssets.getExpectedFiles())

		assert.eq(url, "https://raw.githubusercontent.com/owner/repo/main/.github/assets")
		assert.eq(reason, nil)
	end)

	suite:case("encodes the branch and folder for the URL", function(assert)
		local repository: buttonAssets.Repository =
			{ name = "owner/repo", defaultBranch = "release/v 2", private = false }
		local url = buttonAssets.findBaseUrl(repository, "my assets", buttonAssets.getExpectedFiles())

		assert.eq(url, "https://raw.githubusercontent.com/owner/repo/release/v%202/my%20assets")
	end)

	suite:case("falls back for private repositories", function(assert)
		local repository: buttonAssets.Repository = { name = "owner/repo", defaultBranch = "main", private = true }
		local url, reason = buttonAssets.findBaseUrl(repository, ".github/assets", buttonAssets.getExpectedFiles())

		assert.eq(url, nil)
		assert.strContains(reason :: string, "private")
	end)

	suite:case("names the missing files", function(assert)
		local url, reason = buttonAssets.findBaseUrl(PUBLIC, ".github/assets", { "join-light.svg" })

		assert.eq(url, nil)
		assert.strContains(reason :: string, ".github/assets on main is missing join-dark.svg")
	end)
end)
