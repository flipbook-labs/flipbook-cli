local function percentEncode(value: string): string
	local encoded: { string } = {}
	for index = 1, #value do
		local character = string.sub(value, index, index)
		if character:match("^[%w%-%._~]$") then
			table.insert(encoded, character)
		else
			table.insert(encoded, string.format("%%%02X", string.byte(value, index)))
		end
	end
	return table.concat(encoded)
end

return percentEncode
