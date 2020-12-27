local LuaUnit = require("luaunit")

local Buffer = require("Buffer")

local WriterTest = {}

local function TestNew_WithBuffer()
	local buf = Buffer.New()
	local o = buf:GetWriter()

	LuaUnit.assertEquals(o:GetIndex(), 1)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function WriterTest:TestNew_WithBuffer()
	TestNew_WithBuffer()
end

local function TestNew_WithBufferAndNumber(index)
	local buf = Buffer.New()
	local o = buf:GetWriter(index)

	LuaUnit.assertEquals(o:GetIndex(), index)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function WriterTest:TestNew_WithBufferAndNumber()
	TestNew_WithBufferAndNumber(1)
	TestNew_WithBufferAndNumber(8)
end

local function TestNew_WithBufferAndNumberAndNumber(index, begin)
	local buf = Buffer.New()
	local o = buf:GetWriter(index, begin)

	LuaUnit.assertEquals(o:GetIndex(), index)
	LuaUnit.assertEquals(o:GetBegin(), begin)
end

function WriterTest:TestNew_WithBufferAndNumberAndNumber()
	TestNew_WithBufferAndNumberAndNumber(1, 1)
	TestNew_WithBufferAndNumberAndNumber(8, 1)
	TestNew_WithBufferAndNumberAndNumber(1, 8)
end

local function TestSet_WithNumberAndNumber(index, begin, count, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local buf = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	local o = buf:GetWriter(index, begin)

	o:Set(count, value)
	o:Set(count, value)

	LuaUnit.assertEquals(tostring(buf), x)
end

function WriterTest:TestSet_WithNumberAndNumber()
	TestSet_WithNumberAndNumber(1, 1, 8, 0xaa, "\170\170\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(8, 5, 8, 0xaa, "\069\040\033\230\056\208\019\167\170\090\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(1, 1, 64, 0xaa, "\170\000\000\000\000\000\000\000\170\000\000\000\000\000\000\000")
	TestSet_WithNumberAndNumber(1, 1, 64, 0xaaaaaaaaaaaaaaaa, "\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170")
end

local function TestSet_WithNumberAndNumber_WhereNotCanSet(a, index, begin, count, value)
	local buf = Buffer.New(a)
	local o = buf:GetWriter(index, begin)

	LuaUnit.assertError(function ()
		o:Set(count, value)
		o:Set(count, value)
	end)
end

function WriterTest:TestSet_WithNumberAndNumber_WhereNotCanSet()
	TestSet_WithNumberAndNumber_WhereNotCanSet(nil, 1, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanSet("\000\000\000\000\000\000\000\000", 9, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanSet("\000\000\000\000\000\000\000\000", 8, 2, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanSet("\000\000\000\000\000\000\000\000", 8, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanSet("\000\000\000\000\000\000\000\000", 7, 2, 8, 0x0)
end

local function TestSet_WithNumberAndNumberAndBoolean(index, begin, count, value, x)
	local buf = Buffer.New()
	local o = buf:GetWriter(index, begin)

	o:Set(count, value, true)
	o:Set(count, value, true)

	LuaUnit.assertEquals(tostring(buf), x)
end

function WriterTest:TestSet_WithNumberAndNumberAndBoolean()
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 8, 0xaa, "\170\170")
	TestSet_WithNumberAndNumberAndBoolean(8, 5, 8, 0xaa, "\000\000\000\000\000\000\000\160\170\010")
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 64, 0xaa, "\170\000\000\000\000\000\000\000\170\000\000\000\000\000\000\000")
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 64, 0xaaaaaaaaaaaaaaaa, "\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170")
end

return WriterTest
