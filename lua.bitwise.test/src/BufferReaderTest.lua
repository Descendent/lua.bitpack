local LuaUnit = require("luaunit")

local Buffer = require("Buffer")
local BufferReader = require("BufferReader")

local BufferReaderTest = {}

local function TestNew_WithBuffer()
	local buf = Buffer.New()
	local o = BufferReader.New(buf)

	LuaUnit.assertEquals(o:GetIndex(), 1)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function BufferReaderTest:TestNew_WithBuffer()
	TestNew_WithBuffer()
end

local function TestNew_WithBufferAndNumber(index)
	local buf = Buffer.New()
	local o = BufferReader.New(buf, index)

	LuaUnit.assertEquals(o:GetIndex(), index)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function BufferReaderTest:TestNew_WithBufferAndNumber()
	TestNew_WithBufferAndNumber(1)
	TestNew_WithBufferAndNumber(8)
end

local function TestNew_WithBufferAndNumberAndNumber(index, begin)
	local buf = Buffer.New()
	local o = BufferReader.New(buf, index, begin)

	LuaUnit.assertEquals(o:GetIndex(), index)
	LuaUnit.assertEquals(o:GetBegin(), begin)
end

function BufferReaderTest:TestNew_WithBufferAndNumberAndNumber()
	TestNew_WithBufferAndNumberAndNumber(1, 1)
	TestNew_WithBufferAndNumberAndNumber(8, 1)
	TestNew_WithBufferAndNumberAndNumber(1, 8)
end

local function TestGet_WithNumber(index, begin, count, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local buf = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	local o = BufferReader.New(buf, index, begin)

	LuaUnit.assertEquals(o:Get(count), x[1])
	LuaUnit.assertEquals(o:Get(count), x[2])
end

function BufferReaderTest:TestGet_WithNumber()
	TestGet_WithNumber(1, 1, 8, {0x45, 0x28})
	TestGet_WithNumber(8, 5, 8, {0xe7, 0x4b})
	TestGet_WithNumber(1, 1, 32, {0xe6212845, 0x7713d038})
end

local function TestGet_WithNumber_WhereNotCanHas(a, index, begin, count)
	local buf = Buffer.New(a)
	local o = BufferReader.New(buf, index, begin)

	LuaUnit.assertError(function ()
		o:Get(count)
		o:Get(count)
	end)
end

function BufferReaderTest:TestGet_WithNumber_WhereNotCanHas()
	TestGet_WithNumber_WhereNotCanHas(nil, 1, 1, 8)
	TestGet_WithNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 9, 1, 8)
	TestGet_WithNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 8, 2, 8)
	TestGet_WithNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 8, 1, 8)
	TestGet_WithNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 7, 2, 8)
end

local function TestGetSignify_WithNumber(a, index, begin, count, x)
	local buf = Buffer.New(a)
	local o = BufferReader.New(buf, index, begin)

	LuaUnit.assertEquals(o:GetSignify(count), x)
end

function BufferReaderTest:TestGetSignify_WithNumber()
	TestGetSignify_WithNumber("\255", 1, 1, 8, 127)
	TestGetSignify_WithNumber("\000", 1, 1, 8, -128)
	TestGetSignify_WithNumber("\128", 1, 1, 8, 0)
	TestGetSignify_WithNumber("\001", 1, 1, 1, 0)
	TestGetSignify_WithNumber("\003", 1, 1, 2, 1)
	TestGetSignify_WithNumber("\000", 1, 1, 1, -1)
	TestGetSignify_WithNumber("\255\255\255\255", 1, 1, 32, (1 << 31) - 1)
	TestGetSignify_WithNumber("\000\000\000\000", 1, 1, 32, -(1 << 31))
	TestGetSignify_WithNumber("\240\015", 1, 5, 8, 127)
	TestGetSignify_WithNumber("\000\000", 1, 5, 8, -128)
	TestGetSignify_WithNumber("\000\008", 1, 5, 8, 0)
	TestGetSignify_WithNumber("\128", 1, 8, 1, 0)
	TestGetSignify_WithNumber("\128\001", 1, 8, 2, 1)
	TestGetSignify_WithNumber("\000", 1, 8, 1, -1)
end

local function TestGetNillify_WithNumber(a, index, begin, count, x)
	local buf = Buffer.New(a)
	local o = BufferReader.New(buf, index, begin)

	LuaUnit.assertEquals(o:GetNillify(count), x)
end

function BufferReaderTest:TestGetNillify_WithNumber()
	TestGetNillify_WithNumber("\000", 1, 1, 8, nil)
	TestGetNillify_WithNumber("\255", 1, 1, 8, 255)
end

local function TestGetBoolean_WithNumber(a, index, begin, count, x)
	local buf = Buffer.New(a)
	local o = BufferReader.New(buf, index, begin)

	LuaUnit.assertEquals(o:GetBoolean(count), x)
end

function BufferReaderTest:TestGetBoolean_WithNumber()
	TestGetBoolean_WithNumber("\000", 1, 1, 1, false)
	TestGetBoolean_WithNumber("\001", 1, 1, 1, true)
	TestGetBoolean_WithNumber("\000", 1, 1, 8, false)
	TestGetBoolean_WithNumber("\255", 1, 1, 8, true)
end

return BufferReaderTest
