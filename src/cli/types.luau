local cli = require("@batteries/cli")

export type Command = {
	summary: string,
	configure: (cli.Parser) -> (),
	run: (cli.Parser) -> (),
}

return nil
