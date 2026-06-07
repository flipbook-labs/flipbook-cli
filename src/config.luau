local process = require("@std/process")

return {
	rojoCmd = process.env.FLIPBOOK_ROJO_CMD or "rojo",
	gitCmd = process.env.FLIPBOOK_GIT_CMD or "git",
	ghCmd = process.env.FLIPBOOK_GH_CMD or "gh",
	gitCliffCmd = process.env.FLIPBOOK_GIT_CLIFF_CMD or "git-cliff",
}
