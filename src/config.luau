local process = require("@std/process")

return {
	rojoCmd = process.env.FLIPBOOK_ROJO_CMD or "rojo",
}
