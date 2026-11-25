local FlipbookBatteries = require("@lpm/flipbook-batteries@v0.13.1")
local cli = require("@root/cli")

FlipbookBatteries.dotenv()

cli.run({ ... })
