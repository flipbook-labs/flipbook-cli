local makeCommandGroup = require("@root/cli/makeCommandGroup")

local attachCommand = require("@self/attach")
local draftCommand = require("@self/draft")
local gateCommand = require("@self/gate")
local preparePrCommand = require("@self/preparePr")

return makeCommandGroup({
	name = "release",
	title = "release",
	summary = "Manage the release lifecycle (gate, draft, attach, prepare-pr).",
	subcommands = {
		gate = gateCommand,
		draft = draftCommand,
		attach = attachCommand,
		["prepare-pr"] = preparePrCommand,
	},
	order = { "gate", "draft", "attach", "prepare-pr" },
})
