local cli = require("@root/cli")
local dotenv = require("@pkg/dotenv@v0.1.0/src")

-- We wrap this in a pcall since if a `.env` does not exist dotenv will throw,
-- which we don't want.
pcall(function()
	dotenv.config()
end)

cli.run({ ... })
