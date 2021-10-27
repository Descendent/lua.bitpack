local Buffer = {}
Buffer.__index = Buffer

--------------------------------------------------------------------------------

local Reader = {}
Reader.__index = Reader

function Reader.New(buf, index, begin)
	if index == nil then
		index = 1
	end

	if begin == nil then
		begin = 1
	end

	local self = setmetatable({}, Reader)

	self._buf = buf
	self._index = index
	self._begin = begin

	return self
end

function Reader:GetIndex()
	return self._index
end

function Reader:SetIndex(value)
	self._index = value
end

function Reader:GetBegin()
	return self._begin
end

function Reader:SetBegin(value)
	self._begin = value
end

function Reader:CanGet(count)
	return self._buf:CanGet(self._index, self._begin, count)
end

function Reader:Get(count)
	local value = self._buf:Get(self._index, self._begin, count)
	self._index, self._begin = Buffer.Increment(self._index, self._begin, count)

	return value
end

function Reader:GetSignify(count)
	return self:Get(count) - (1 << (count - 1))
end

function Reader:GetNillify(count)
	local value = self:Get(count)

	if value == 0 then
		return nil
	end

	return value
end

function Reader:GetBoolean(count)
	return (self:Get(count) ~= 0)
end

--------------------------------------------------------------------------------

local Writer = {}
Writer.__index = Writer

function Writer.New(buf, index, begin)
	if index == nil then
		index = 1
	end

	if begin == nil then
		begin = 1
	end

	local self = setmetatable({}, Writer)

	self._buf = buf
	self._index = index
	self._begin = begin

	return self
end

function Writer:GetIndex()
	return self._index
end

function Writer:SetIndex(value)
	self._index = value
end

function Writer:GetBegin()
	return self._begin
end

function Writer:SetBegin(value)
	self._begin = value
end

function Writer:CanSet(count)
	return self._buf:CanSet(self._index, self._begin, count)
end

function Writer:Set(count, value, reserve)
	if reserve then
		self._buf:Reserve(self._index, self._begin, count)
	end

	self._buf:Set(self._index, self._begin, count, value)
	self._index, self._begin = Buffer.Increment(self._index, self._begin, count)
end

function Writer:SetSignify(count, value, reserve)
	self:Set(count, value + (1 << (count - 1)), reserve)
end

function Writer:SetNillify(count, value, reserve)
	if value == nil then
		value = 0
	end

	self:Set(count, value, reserve)
end

function Writer:SetBoolean(count, value, reserve)
	if value == 0 then
		--
	elseif not value then
		value = 0
	else
		value = 1
	end

	self:Set(count, value, reserve)
end

--------------------------------------------------------------------------------

Buffer.DEBUG = true

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

local function Encode(bin, len)
	if len == 0 then
		return ""
	end

	local str = {}

	local o
	local i = 1
	local j = 1
	while i <= #bin do
		o = bin[i] & 0xffffffff
		o = ((o & 0x000000ff) << 24) | ((o & 0x0000ff00) << 8) | ((o & 0x00ff0000) >> 8) | ((o & 0xff000000) >> 24) -- Little-endian to big-endian

		str[j    ] = ENCODE[1 + ((o // 52200625) % 85)]
		str[j + 1] = ENCODE[1 + ((o // 614125) % 85)]
		str[j + 2] = ENCODE[1 + ((o // 7225) % 85)]
		str[j + 3] = ENCODE[1 + ((o // 85) % 85)]
		str[j + 4] = ENCODE[1 + (o % 85)]

		o = bin[i] >> 32
		o = ((o & 0x000000ff) << 24) | ((o & 0x0000ff00) << 8) | ((o & 0x00ff0000) >> 8) | ((o & 0xff000000) >> 24) -- Little-endian to big-endian

		str[j + 5] = ENCODE[1 + ((o // 52200625) % 85)]
		str[j + 6] = ENCODE[1 + ((o // 614125) % 85)]
		str[j + 7] = ENCODE[1 + ((o // 7225) % 85)]
		str[j + 8] = ENCODE[1 + ((o // 85) % 85)]
		str[j + 9] = ENCODE[1 + (o % 85)]

		i = i + 1
		j = j + 10
	end

	return table.concat(str, "", 1, (math.ceil(len / 4) * 5) - (4 - (((len - 1) % 4) + 1)))
end

local function Decode(str)
	if str == "" then
		return {}, 0
	end

	if Buffer.DEBUG then
		assert(#str % 5 ~= 1)
	end

	local STRING_UNPACK = string.unpack

	local bin = {}

	local a1, a2, a3, a4, a5
	local b1, b2, b3, b4, b5
	local a
	local b
	local i = 1
	local j = 1
	while i <= (#str // 10) * 10 do
		a1, a2, a3, a4, a5, b1, b2, b3, b4, b5 = STRING_UNPACK(">BBBBBBBBBB", str, i)

		a = DECODE[a1 - 31] * 52200625
			+ DECODE[a2 - 31] * 614125
			+ DECODE[a3 - 31] * 7225
			+ DECODE[a4 - 31] * 85
			+ DECODE[a5 - 31]
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Big-endian to little-endian

		b = DECODE[b1 - 31] * 52200625
			+ DECODE[b2 - 31] * 614125
			+ DECODE[b3 - 31] * 7225
			+ DECODE[b4 - 31] * 85
			+ DECODE[b5 - 31]
		b = ((b & 0x000000ff) << 24) | ((b & 0x0000ff00) << 8) | ((b & 0x00ff0000) >> 8) | ((b & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[j] = a | (b << 32)

		i = i + 10
		j = j + 1
	end

	local shift = 0

	if #str % 10 >= 5 then
		a1, a2, a3, a4, a5 = STRING_UNPACK(">BBBBB", str, i)

		a = DECODE[a1 - 31] * 52200625
			+ DECODE[a2 - 31] * 614125
			+ DECODE[a3 - 31] * 7225
			+ DECODE[a4 - 31] * 85
			+ DECODE[a5 - 31]
		a = ((a & 0x000000ff) << 24) | ((a & 0x0000ff00) << 8) | ((a & 0x00ff0000) >> 8) | ((a & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[j] = a

		i = i + 5
		shift = 1
	else
		a = 0
	end

	if #str % 5 == 4 then
		b1, b2, b3, b4 = STRING_UNPACK(">BBBB", str, i)

		b = DECODE[b1 - 31] * 52200625
			+ DECODE[b2 - 31] * 614125
			+ DECODE[b3 - 31] * 7225
			+ DECODE[b4 - 31] * 85
			+ 84
		b = b & 0xffffff00
		b = ((b & 0x000000ff) << 24) | ((b & 0x0000ff00) << 8) | ((b & 0x00ff0000) >> 8) | ((b & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[j] = a | (b << (32 * shift))
	elseif #str % 5 == 3 then
		b1, b2, b3 = STRING_UNPACK(">BBB", str, i)

		b = DECODE[b1 - 31] * 52200625
			+ DECODE[b2 - 31] * 614125
			+ DECODE[b3 - 31] * 7225
			+ 84 * 85
			+ 84
		b = b & 0xffff0000
		b = ((b & 0x000000ff) << 24) | ((b & 0x0000ff00) << 8) | ((b & 0x00ff0000) >> 8) | ((b & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[j] = a | (b << (32 * shift))
	elseif #str % 5 == 2 then
		b1, b2 = STRING_UNPACK(">BB", str, i)

		b = DECODE[b1 - 31] * 52200625
			+ DECODE[b2 - 31] * 614125
			+ 84 * 7225
			+ 84 * 85
			+ 84
		b = b & 0xff000000
		b = ((b & 0x000000ff) << 24) | ((b & 0x0000ff00) << 8) | ((b & 0x00ff0000) >> 8) | ((b & 0xff000000) >> 24) -- Big-endian to little-endian

		bin[j] = a | (b << (32 * shift))
	end

	return bin, (math.ceil(#str / 5) * 4) - (5 - (((#str - 1) % 5) + 1))
end

function Buffer.New(str)
	if str == nil then
		str = ""
	end

	local self = setmetatable({}, Buffer)

	self._bin, self._len = Decode(str)
	self._n = #self._bin

	return self
end

function Buffer.Normalize(index, begin)
	return index + ((begin - 1) // 8),
		((begin - 1) % 8) + 1
end

function Buffer.Increment(index, begin, count)
	return Buffer.Normalize(index, begin + count)
end

local function CanHas(self, index, begin, count)
	if (begin == nil) and (count == nil) then
		begin = 1
		count = 8
	end

	if Buffer.DEBUG then
		assert(index >= 1)
		assert(index == index << 0)

		assert(begin >= 1)
		assert(begin <= 8)
		assert(begin == begin << 0)

		assert(count >= 1)
		assert(count <= 64)
		assert(count == count << 0)
	end

	return (Buffer.Increment(index, begin, count - 1) <= self._len)
end

function Buffer:CanGet(index, begin, count)
	return CanHas(self, index, begin, count)
end

function Buffer:CanSet(index, begin, count)
	return CanHas(self, index, begin, count)
end

function Buffer:Get(index, begin, count)
	if (begin == nil) and (count == nil) then
		begin = 1
		count = 8
	end

	if Buffer.DEBUG then
		assert(index >= 1)

		assert(begin >= 1)
		assert(begin <= 8)

		assert(count >= 1)
		assert(count <= 64)
	end

	local i = ((index - 1) // 8) + 1

	local aBegin = (((index - 1) % 8) * 8) + begin
	local aCount = math.min(count, 64 - (aBegin - 1))
	local a = (self._bin[i] >> (aBegin - 1))
		& ((1 << aCount) - 1)

	if aCount == count then
		return a
	end

	i = i + 1

	local bCount = count - aCount
	local b = self._bin[i]
		& ((1 << bCount) - 1)

	return a | (b << aCount)
end

function Buffer:Set(index, begin, count, value)
	if (count == nil) and (value == nil) then
		value = begin
		begin = 1
		count = 8
	end

	if Buffer.DEBUG then
		assert(index >= 1)

		assert(begin >= 1)
		assert(begin <= 8)

		assert(count >= 1)
		assert(count <= 64)

		assert(value == value & ((1 << count) - 1))
	end

	local i = ((index - 1) // 8) + 1

	local aBegin = (((index - 1) % 8) * 8) + begin
	local aCount = math.min(count, 64 - (aBegin - 1))
	self._bin[i] = (self._bin[i] & ~(((1 << aCount) - 1) << (aBegin - 1))) -- Clear
		| ((value & ((1 << aCount) - 1)) << (aBegin - 1))

	if aCount == count then
		return
	end

	i = i + 1

	local bCount = count - aCount
	self._bin[i] = (self._bin[i] & ~((1 << bCount) - 1)) -- Clear
		| ((value >> aCount) & ((1 << bCount) - 1))
end

local function Reserve_0(self)
	self._len = 0
	self._n = 0
	self._bin = {}
end

local function Reserve_N(self, index, begin, count)
	local n = ((index - 1) // 8) + 1

	for i = self._n + 1, n do
		self._bin[i] = 0
	end

	for i = n + 1, self._n do
		self._bin[i] = nil
	end

	local aCount = (((index - 1) % 8) * 8) + count
	self._bin[n] = self._bin[n] & ((1 << aCount) - 1)

	if index == self._len then
		return
	end

	self._len = index
	self._n = n
end

function Buffer:Reserve(index, begin, count)
	if (begin == nil) and (count == nil) then
		begin = 1
		count = 8
	end

	if Buffer.DEBUG then
		assert(index >= 0)

		assert(begin >= 1)
		assert(begin <= 8)

		assert(count >= 0)
	end

	index, count = Buffer.Increment(index, begin, count - 1)
	begin = 1

	if index == 0 then
		Reserve_0(self)
	else
		Reserve_N(self, index, begin, count)
	end
end

function Buffer:__len()
	return self._len
end

function Buffer:__tostring()
	return Encode(self._bin, self._len)
end

function Buffer:GetReader(index, begin)
	return Reader.New(self, index, begin)
end

function Buffer:GetWriter(index, begin)
	return Writer.New(self, index, begin)
end

return Buffer
