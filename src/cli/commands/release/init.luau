local makeCommandGroup = require("@root/cli/makeCommandGroup")

local attachCommand = require("@self/attach")
local gateCommand = require("@self/gate")
local preparePrCommand = require("@self/preparePr")
local publishCommand = require("@self/publish")

return makeCommandGroup({
	name = "release",
	title = "release",
	summary = "Manage the release lifecycle (gate, publish, attach, prepare-pr).",
	subcommands = {
		gate = gateCommand,
		publish = publishCommand,
		attach = attachCommand,
		["prepare-pr"] = preparePrCommand,
	},
	order = { "gate", "publish", "attach", "prepare-pr" },
})
