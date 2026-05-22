local cli = require("@root/cli")
local dotenv = require("@pkg/dotenv@v0.1.0/src")

dotenv.config()

cli.run({ ... })
