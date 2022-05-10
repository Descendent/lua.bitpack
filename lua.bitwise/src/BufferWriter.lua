local BufferWriter = {}
BufferWriter.__index = BufferWriter

function BufferWriter.New(buf, octet, bitBegin)
	if octet == nil then
		octet = 1
	end

	if bitBegin == nil then
		bitBegin = 1
	end

	local self = setmetatable({}, BufferWriter)

	self._buf = buf
	self._octet = octet
	self._bitBegin = bitBegin

	return self
end

function BufferWriter:GetOctet()
	return self._octet
end

function BufferWriter:SetOctet(value)
	self._octet = value
end

function BufferWriter:GetBitBegin()
	return self._bitBegin
end

function BufferWriter:SetBitBegin(value)
	self._bitBegin = value
end

function BufferWriter:CanHas(bitCount)
	return self._buf:CanHas(self._octet, self._bitBegin, bitCount)
end

function BufferWriter:Set(bitCount, value, reserve)
	if reserve then
		self:Reserve(bitCount)
	end

	self._buf:Set(self._octet, self._bitBegin, bitCount, value)
	self._octet, self._bitBegin = self._buf.Increment(self._octet, self._bitBegin, bitCount)
end

function BufferWriter:SetSignify(bitCount, value, reserve)
	self:Set(bitCount, value + (1 << (bitCount - 1)), reserve)
end

function BufferWriter:SetNillify(bitCount, value, reserve)
	if value == nil then
		value = 0
	end

	self:Set(bitCount, value, reserve)
end

function BufferWriter:SetBoolify(bitCount, value, reserve)
	if value == 0 then
		--
	elseif not value then
		value = 0
	else
		value = 1
	end

	self:Set(bitCount, value, reserve)
end

function BufferWriter:Reserve(bitCount)
	self._buf:Reserve(self._octet, self._bitBegin, bitCount)
end

return BufferWriter
