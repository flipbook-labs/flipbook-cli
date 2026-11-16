local FlipbookBatteries = require("@flipbook-batteries")
local cli = require("@root/cli")

FlipbookBatteries.dotenv()

cli.run({ ... })
