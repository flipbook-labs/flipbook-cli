local process = require("@std/process")

return {
	rocaleCmd = process.env.FLIPBOOK_ROCALE_CMD or "rocale-cli",
	rojoCmd = process.env.FLIPBOOK_ROJO_CMD or "rojo",
}
