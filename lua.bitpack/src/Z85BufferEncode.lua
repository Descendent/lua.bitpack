local Z85BufferEncode = {}
Z85BufferEncode.__index = Z85BufferEncode

-- https://rfc.zeromq.org/spec/32/
-- https://en.wikipedia.org/wiki/Ascii85#Adobe_version

local ENCODE = {
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
	"k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
	"u", "v", "w", "x", "y", "z", "A", "B", "C", "D",
	"E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
	"O", "P", "Q", "R", "S", "T", "U", "V", "W", "X",
	"Y", "Z", ".", "-", ":", "+", "=", "^", "!", "/",
	"*", "?", "&", "<", ">", "(", ")", "[", "]", "{",
	"}", "@", "%", "$", "#"
}

function Z85BufferEncode.New(buf, str)
	if str == nil then
		str = {}
	end

	assert(next(str) == nil)

	local self = setmetatable({}, Z85BufferEncode)

	self._buf = buf
	self._str = str

	self._len = 0
	self._binIndex = 1
	self._strIndex = 1

	return self
end

function Z85BufferEncode:GetBuffer()
	return self._buf
end

function Z85BufferEncode:GetString()
	return table.concat(self._str, "", 1, (math.ceil(self._len / 4) * 5) - (4 - (((self._len - 1) % 4) + 1)))
end

function Z85BufferEncode:GetRemaining()
	return #self._buf - self._len
end

function Z85BufferEncode:Process(count)
	if count == 0 then
		return
	end

	local buf = self._buf
	local bin = buf._bin
	local str = self._str

	if #buf == 0 then
		return
	end

	local len = math.min(math.ceil(count / 4) * 4,
		#buf - self._len)

	if len == 0 then
		return
	end

	local binIndex = self._binIndex
	local strIndex = self._strIndex
	local a
	for i = 1, len, 4 do
		a = bin[binIndex]
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Little-endian to big-endian

		str[strIndex    ] = ENCODE[1 + ((a // 52200625) % 85)]
		str[strIndex + 1] = ENCODE[1 + ((a // 614125) % 85)]
		str[strIndex + 2] = ENCODE[1 + ((a // 7225) % 85)]
		str[strIndex + 3] = ENCODE[1 + ((a // 85) % 85)]
		str[strIndex + 4] = ENCODE[1 + (a % 85)]

		binIndex = binIndex + 1
		strIndex = strIndex + 5
	end

	self._len = self._len + len
	self._binIndex = binIndex
	self._strIndex = strIndex
end

return Z85BufferEncode
