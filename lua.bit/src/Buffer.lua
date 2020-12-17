local Buffer = {}
Buffer.__index = Buffer

local function GetFormatter(self)
	-- Format-string for `string.pack` and `string.unpack`
	-- https://www.lua.org/manual/5.3/manual.html#6.4.2

	return "<" .. string.rep("j", self._len // 8)
		.. string.rep("I" .. (self._len % 8), math.min(1, self._len % 8))
end

function Buffer.New(str)
	if str == nil then
		str = ""
	end

	local self = setmetatable({}, Buffer)

	self._len = #str
	self._n = ((self._len - 1) // 8) + 1
	self._bin = {string.unpack(GetFormatter(self), str)}
	table.remove(self._bin)

	return self
end

function Buffer.Normalize(index, begin)
	return index + ((begin - 1) // 8),
		((begin - 1) % 8) + 1
end

function Buffer.Increment(index, begin, count)
	return Buffer.Normalize(index, begin + count)
end

function Buffer:Get(index, begin, count)
	if (begin == nil) and (count == nil) then
		begin = 1
		count = 8
	end

	assert(index >= 1)

	assert(begin >= 1)
	assert(begin <= 8)

	assert(count >= 1)
	assert(count <= 64)

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

	assert(index >= 1)

	assert(begin >= 1)
	assert(begin <= 8)

	assert(count >= 1)
	assert(count <= 64)

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
	index, count = Buffer.Increment(index, begin, count - 1)
	begin = 1

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
	self._bin[0] = nil
end

function Buffer:Reserve(index, begin, count)
	if (begin == nil) and (count == nil) then
		begin = 1
		count = 8
	end

	assert(index >= 0)

	assert(begin >= 1)
	assert(begin <= 8)

	assert(count >= 1)
	assert(count <= 64)

	if index == 0 then
		Reserve_0(self)
	else
		Reserve_N(self, index, begin, count)
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
