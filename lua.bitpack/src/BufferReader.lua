local BufferReader = {}
BufferReader.__index = BufferReader

function BufferReader.New(buf, octet, bitBegin)
	if octet == nil then
		octet = 1
	end

	if bitBegin == nil then
		bitBegin = 1
	end

	local self = setmetatable({}, BufferReader)

	self._buf = buf
	self._octet, self._bitBegin = self._buf.Normalize(octet, bitBegin)

	return self
end

function BufferReader:GetCurrent()
	return self._octet, self._bitBegin
end

function BufferReader:SetCurrent(octet, bitBegin)
	self._octet, self._bitBegin = self._buf.Normalize(octet, bitBegin)
end

function BufferReader:CanHas(bitCount)
	return self._buf:CanHas(self._octet, self._bitBegin, bitCount)
end

function BufferReader:Get(bitCount)
	local value = self._buf:Get(self._octet, self._bitBegin, bitCount)
	self._octet, self._bitBegin = self._buf.Increment(self._octet, self._bitBegin, bitCount)

	return value
end

function BufferReader:GetSignify(bitCount)
	return self:Get(bitCount) - (1 << (bitCount - 1))
end

function BufferReader:GetNillify(bitCount)
	local value = self:Get(bitCount)

	if value == 0 then
		return nil
	end

	return value
end

function BufferReader:GetBoolify(bitCount)
	return (self:Get(bitCount) ~= 0)
end

return BufferReader
