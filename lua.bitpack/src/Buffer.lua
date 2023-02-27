local function Quote(value)
	local t = type(value)

	if t == "string" then
		return string.format("%q", value)
	end

	if t == "table" then
		return string.format("[%s]", value)
	end

	if t == "function" then
		return string.format("[%s]", value)
	end

	if t == "thread" then
		return string.format("[%s]", value)
	end

	if t == "userdata" then
		return string.format("[%s]", value)
	end

	return value
end

--------------------------------------------------------------------------------

local Buffer = {}
Buffer.__index = Buffer

local _debug = true

function Buffer.ConfigureDebug(value)
	_debug = value
end

function Buffer.Normalize(octet, bitBegin)
	return octet + ((bitBegin - 1) // 8),
		((bitBegin - 1) % 8) + 1
end

function Buffer.Increment(octet, bitBegin, bitCount)
	return Buffer.Normalize(octet, bitBegin + bitCount)
end

local function GetFormatter(self)
	-- Format-string for `string.pack` and `string.unpack`
	-- https://www.lua.org/manual/5.3/manual.html#6.4.2

	return "<" .. string.rep("I4", self._len // 4)
		.. string.rep("I" .. (self._len % 4), math.min(1, self._len % 4))
end

function Buffer.New(str)
	if str == nil then
		str = ""
	end

	local self = setmetatable({}, Buffer)

	self._len = #str
	self._n = ((self._len - 1) // 4) + 1
	self._bin = {string.unpack(GetFormatter(self), str)}
	table.remove(self._bin)

	return self
end

function Buffer:CanHas(octet, bitBegin, bitCount)
	if (bitBegin == nil) and (bitCount == nil) then
		bitBegin = 1
		bitCount = 8
	end

	if _debug then
		assert(octet >= 1,
			string.format("invalid argument: octet=%s", Quote(octet)))
		assert(octet == octet << 0,
			string.format("invalid argument: octet=%s", Quote(octet)))

		assert(bitBegin >= 1,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))
		assert(bitBegin <= 8,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))
		assert(bitBegin == bitBegin << 0,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))

		assert(bitCount >= 1,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))
		assert(bitCount == bitCount << 0,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))
	end

	return (Buffer.Increment(octet, bitBegin, bitCount - 1) <= self._len)
end

function Buffer:Get(octet, bitBegin, bitCount)
	if (bitBegin == nil) and (bitCount == nil) then
		bitBegin = 1
		bitCount = 8
	end

	if _debug then
		assert(octet >= 1,
			string.format("invalid argument: octet=%s", Quote(octet)))

		assert(bitBegin >= 1,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))
		assert(bitBegin <= 8,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))

		assert(bitCount >= 1,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))
		assert(bitCount <= 32,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))

		assert(Buffer.Increment(octet, bitBegin, bitCount - 1) <= self._len,
			string.format("invalid argument: octet=%s, bitBegin=%s, bitCount=%s", Quote(octet), Quote(bitBegin), Quote(bitCount)))
	end

	local i = ((octet - 1) // 4) + 1

	local aBitBegin = (((octet - 1) % 4) * 8) + bitBegin
	local aBitCount = math.min(bitCount, 32 - (aBitBegin - 1))
	local a = (self._bin[i] >> (aBitBegin - 1))
		& ((1 << aBitCount) - 1)

	if aBitCount == bitCount then
		return a
	end

	i = i + 1

	local bBitCount = bitCount - aBitCount
	local b = self._bin[i]
		& ((1 << bBitCount) - 1)

	return a | (b << aBitCount)
end

function Buffer:Set(octet, bitBegin, bitCount, value)
	if (bitCount == nil) and (value == nil) then
		value = bitBegin
		bitBegin = 1
		bitCount = 8
	end

	if _debug then
		assert(octet >= 1,
			string.format("invalid argument: octet=%s", Quote(octet)))

		assert(bitBegin >= 1,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))
		assert(bitBegin <= 8,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))

		assert(bitCount >= 1,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))
		assert(bitCount <= 32,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))

		assert(Buffer.Increment(octet, bitBegin, bitCount - 1) <= self._len,
			string.format("invalid argument: octet=%s, bitBegin=%s, bitCount=%s", Quote(octet), Quote(bitBegin), Quote(bitCount)))

		assert(value == value & ((1 << bitCount) - 1),
			string.format("invalid argument: value=%s", Quote(value)))
	end

	local i = ((octet - 1) // 4) + 1

	local aBitBegin = (((octet - 1) % 4) * 8) + bitBegin
	local aBitCount = math.min(bitCount, 32 - (aBitBegin - 1))
	self._bin[i] = (self._bin[i] & ~(((1 << aBitCount) - 1) << (aBitBegin - 1))) -- Clear
		| ((value & ((1 << aBitCount) - 1)) << (aBitBegin - 1))

	if aBitCount == bitCount then
		return
	end

	i = i + 1

	local bBitCount = bitCount - aBitCount
	self._bin[i] = (self._bin[i] & ~((1 << bBitCount) - 1)) -- Clear
		| ((value >> aBitCount) & ((1 << bBitCount) - 1))
end

local function Reserve_0(self)
	self._len = 0
	self._n = 0
	self._bin = {}
end

local function Reserve_N(self, octet, bitBegin, bitCount)
	local n = ((octet - 1) // 4) + 1

	for i = self._n + 1, n do
		self._bin[i] = 0
	end

	for i = n + 1, self._n do
		self._bin[i] = nil
	end

	local aBitCount = (((octet - 1) % 4) * 8) + bitCount
	self._bin[n] = self._bin[n] & ((1 << aBitCount) - 1)

	if octet == self._len then
		return
	end

	self._len = octet
	self._n = n
	self._bin[0] = nil
end

function Buffer:Reserve(octet, bitBegin, bitCount)
	if (bitBegin == nil) and (bitCount == nil) then
		bitBegin = 1
		bitCount = 8
	end

	if _debug then
		assert(octet >= 0,
			string.format("invalid argument: octet=%s", Quote(octet)))

		assert(bitBegin >= 1,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))
		assert(bitBegin <= 8,
			string.format("invalid argument: bitBegin=%s", Quote(bitBegin)))

		assert(bitCount >= 0,
			string.format("invalid argument: bitCount=%s", Quote(bitCount)))
	end

	octet, bitCount = Buffer.Increment(octet, bitBegin, bitCount - 1)
	bitBegin = 1

	if octet == 0 then
		Reserve_0(self)
	else
		Reserve_N(self, octet, bitBegin, bitCount)
	end
end

function Buffer:__len()
	return self._len
end

local function Refresh(self)
	if self._bin[0] ~= nil then
		return
	end

	self._bin[0] = GetFormatter(self)
end

function Buffer:__tostring()
	Refresh(self)

	return string.pack(table.unpack(self._bin, 0, self._n))
end

return Buffer
