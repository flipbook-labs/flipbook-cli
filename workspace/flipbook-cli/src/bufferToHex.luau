local function bufferToHex(buf: buffer): string
	local result = {}
	for i = 0, buffer.len(buf) - 1 do
		table.insert(result, string.format("%02x", buffer.readu8(buf, i)))
	end
	return table.concat(result)
end

return bufferToHex
