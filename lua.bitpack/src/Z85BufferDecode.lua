local Z85BufferDecode = {}
Z85BufferDecode.__index = Z85BufferDecode

-- https://rfc.zeromq.org/spec/32/
-- https://en.wikipedia.org/wiki/Ascii85#Adobe_version

local DECODE = {
	 nil, 0x44,  nil, 0x54, 0x53, 0x52, 0x48,  nil,
	0x4B, 0x4C, 0x46, 0x41,  nil, 0x3F, 0x3E, 0x45,
	0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
	0x08, 0x09, 0x40,  nil, 0x49, 0x42, 0x4A, 0x47,
	0x51, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A,
	0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32,
	0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A,
	0x3B, 0x3C, 0x3D, 0x4D,  nil, 0x4E, 0x43,  nil,
	 nil, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
	0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20,
	0x21, 0x22, 0x23, 0x4F,  nil, 0x50,  nil,  nil
}

function Z85BufferDecode.New(buf, str)
	assert(#buf == 0)

	assert(#str % 5 ~= 1)

	local self = setmetatable({}, Z85BufferDecode)

	self._buf = buf
	self._str = str

	self._len = 0
	self._binIndex = 1
	self._strIndex = 1

	return self
end

function Z85BufferDecode:GetBuffer()
	return self._buf
end

function Z85BufferDecode:GetString()
	return self._str
end

function Z85BufferDecode:GetRemaining()
	return #self._str - self._len
end

function Z85BufferDecode:Process(count)
	if count == 0 then
		return
	end

	local buf = self._buf
	local bin = buf._bin
	local str = self._str

	if #str == 0 then
		return
	end

	local len = math.min(math.ceil(count / 5) * 5,
		#str - self._len)

	if len == 0 then
		return
	end

	local string_unpack = string.unpack

	local binIndex = self._binIndex
	local strIndex = self._strIndex
	local a1, a2, a3, a4, a5
	local a
	for i = 1, (len // 5) * 5, 5 do
		a1, a2, a3, a4, a5 = string_unpack(">BBBBB", str, strIndex)

		a = DECODE[a1 - 31] * 52200625
			+ DECODE[a2 - 31] * 614125
			+ DECODE[a3 - 31] * 7225
			+ DECODE[a4 - 31] * 85
			+ DECODE[a5 - 31]
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[binIndex] = a

		strIndex = strIndex + 5
		binIndex = binIndex + 1
	end

	if len % 5 == 4 then
		a1, a2, a3, a4 = string_unpack(">BBBB", str, strIndex)

		a = DECODE[a1 - 31] * 52200625
			+ DECODE[a2 - 31] * 614125
			+ DECODE[a3 - 31] * 7225
			+ DECODE[a4 - 31] * 85
			+ 84
		a = a & 0xffffff00
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[binIndex] = a

		strIndex = strIndex + 4
		binIndex = binIndex + 1
	elseif len % 5 == 3 then
		a1, a2, a3 = string_unpack(">BBB", str, strIndex)

		a = DECODE[a1 - 31] * 52200625
			+ DECODE[a2 - 31] * 614125
			+ DECODE[a3 - 31] * 7225
			+ 84 * 85
			+ 84
		a = a & 0xffff0000
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[binIndex] = a

		strIndex = strIndex + 3
		binIndex = binIndex + 1
	elseif len % 5 == 2 then
		a1, a2 = string_unpack(">BB", str, strIndex)

		a = DECODE[a1 - 31] * 52200625
			+ DECODE[a2 - 31] * 614125
			+ 84 * 7225
			+ 84 * 85
			+ 84
		a = a & 0xff000000
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[binIndex] = a

		strIndex = strIndex + 2
		binIndex = binIndex + 1
	end

	self._len = self._len + len
	self._strIndex = strIndex
	self._binIndex = binIndex

	buf._len = (math.ceil(self._len / 5) * 4) - (5 - (((self._len - 1) % 5) + 1))
	buf._n = self._binIndex - 1
end

return Z85BufferDecode
