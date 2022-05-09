local BufferReader = {}
BufferReader.__index = BufferReader

function BufferReader.New(buf, index, begin)
	if index == nil then
		index = 1
	end

	if begin == nil then
		begin = 1
	end

	local self = setmetatable({}, BufferReader)

	self._buf = buf
	self._index = index
	self._begin = begin

	return self
end

function BufferReader:GetIndex()
	return self._index
end

function BufferReader:SetIndex(value)
	self._index = value
end

function BufferReader:GetBegin()
	return self._begin
end

function BufferReader:SetBegin(value)
	self._begin = value
end

function BufferReader:CanHas(count)
	return self._buf:CanHas(self._index, self._begin, count)
end

function BufferReader:Get(count)
	local value = self._buf:Get(self._index, self._begin, count)
	self._index, self._begin = self._buf.Increment(self._index, self._begin, count)

	return value
end

function BufferReader:GetSignify(count)
	return self:Get(count) - (1 << (count - 1))
end

function BufferReader:GetNillify(count)
	local value = self:Get(count)

	if value == 0 then
		return nil
	end

	return value
end

function BufferReader:GetBoolean(count)
	return (self:Get(count) ~= 0)
end

return BufferReader
