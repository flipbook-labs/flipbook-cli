local process = require("@std/process")

return {
	rocaleCmd = process.env.FLIPBOOK_ROCALE_CMD or "rocale-cli",
	luteCmd = process.env.FLIPBOOK_LUTE_CMD or "lute",
	rojoCmd = process.env.FLIPBOOK_ROJO_CMD or "rojo",
	curlCmd = process.env.FLIPBOOK_CURL_CMD or "curl",
	ghCmd = process.env.FLIPBOOK_GH_CMD or "gh",
}
