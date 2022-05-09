local BufferWriter = {}
BufferWriter.__index = BufferWriter

function BufferWriter.New(buf, index, begin)
	if index == nil then
		index = 1
	end

	if begin == nil then
		begin = 1
	end

	local self = setmetatable({}, BufferWriter)

	self._buf = buf
	self._index = index
	self._begin = begin

	return self
end

function BufferWriter:GetIndex()
	return self._index
end

function BufferWriter:SetIndex(value)
	self._index = value
end

function BufferWriter:GetBegin()
	return self._begin
end

function BufferWriter:SetBegin(value)
	self._begin = value
end

function BufferWriter:CanHas(count)
	return self._buf:CanHas(self._index, self._begin, count)
end

function BufferWriter:Set(count, value, reserve)
	if reserve then
		self:Reserve(count)
	end

	self._buf:Set(self._index, self._begin, count, value)
	self._index, self._begin = self._buf.Increment(self._index, self._begin, count)
end

function BufferWriter:SetSignify(count, value, reserve)
	self:Set(count, value + (1 << (count - 1)), reserve)
end

function BufferWriter:SetNillify(count, value, reserve)
	if value == nil then
		value = 0
	end

	self:Set(count, value, reserve)
end

function BufferWriter:SetBoolean(count, value, reserve)
	if value == 0 then
		--
	elseif not value then
		value = 0
	else
		value = 1
	end

	self:Set(count, value, reserve)
end

function BufferWriter:Reserve(count)
	self._buf:Reserve(self._index, self._begin, count)
end

return BufferWriter
