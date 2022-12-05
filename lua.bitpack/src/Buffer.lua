local Buffer = {}
Buffer.__index = Buffer

local _debug = true

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

function Buffer:CanHas(octet, bitBegin, bitCount)
	if (bitBegin == nil) and (bitCount == nil) then
		bitBegin = 1
		bitCount = 8
	end

	if _debug then
		assert(octet >= 1)
		assert(octet == octet << 0)

		assert(bitBegin >= 1)
		assert(bitBegin <= 8)
		assert(bitBegin == bitBegin << 0)

		assert(bitCount >= 1)
		assert(bitCount == bitCount << 0)
	end

	return (Buffer.Increment(octet, bitBegin, bitCount - 1) <= self._len)
end

function Buffer:Get(octet, bitBegin, bitCount)
	if (bitBegin == nil) and (bitCount == nil) then
		bitBegin = 1
		bitCount = 8
	end

	if _debug then
		assert(octet >= 1)

		assert(bitBegin >= 1)
		assert(bitBegin <= 8)

		assert(bitCount >= 1)
		assert(bitCount <= 32)
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
		assert(octet >= 1)

		assert(bitBegin >= 1)
		assert(bitBegin <= 8)

		assert(bitCount >= 1)
		assert(bitCount <= 32)

		assert(value == value & ((1 << bitCount) - 1))
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
		assert(octet >= 0)

		assert(bitBegin >= 1)
		assert(bitBegin <= 8)

		assert(bitCount >= 0)
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
