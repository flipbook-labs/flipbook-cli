local test = require("@std/test")

local version = require("@root/release/version")

test.suite("version.bump", function(suite)
	suite:case("minor bumps the minor and resets the patch", function(assert)
		assert.eq(version.bump("1.2.3", "minor"), "1.3.0")
	end)

	suite:case("patch increments only the patch", function(assert)
		assert.eq(version.bump("1.2.3", "patch"), "1.2.4")
	end)

	suite:case("minor from a zero patch", function(assert)
		assert.eq(version.bump("0.4.0", "minor"), "0.5.0")
	end)
end)

test.suite("version.parse", function(suite)
	suite:case("splits a semver string into components", function(assert)
		local major, minor, patch = version.parse("10.20.30")
		assert.eq(major, 10)
		assert.eq(minor, 20)
		assert.eq(patch, 30)
	end)
end)
