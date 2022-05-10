local LuaUnit = require("luaunit")

local Buffer = require("Buffer")
local BufferWriter = require("BufferWriter")

local BufferWriterTest = {}

local function TestNew_WithBuffer()
	local buf = Buffer.New()
	local o = BufferWriter.New(buf)

	LuaUnit.assertEquals(o:GetIndex(), 1)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function BufferWriterTest:TestNew_WithBuffer()
	TestNew_WithBuffer()
end

local function TestNew_WithBufferAndNumber(octet)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet)

	LuaUnit.assertEquals(o:GetIndex(), octet)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function BufferWriterTest:TestNew_WithBufferAndNumber()
	TestNew_WithBufferAndNumber(1)
	TestNew_WithBufferAndNumber(8)
end

local function TestNew_WithBufferAndNumberAndNumber(octet, bitBegin)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet, bitBegin)

	LuaUnit.assertEquals(o:GetIndex(), octet)
	LuaUnit.assertEquals(o:GetBegin(), bitBegin)
end

function BufferWriterTest:TestNew_WithBufferAndNumberAndNumber()
	TestNew_WithBufferAndNumberAndNumber(1, 1)
	TestNew_WithBufferAndNumberAndNumber(8, 1)
	TestNew_WithBufferAndNumberAndNumber(1, 8)
end

local function TestSet_WithNumberAndNumber(octet, bitBegin, bitCount, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local buf = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	local o = BufferWriter.New(buf, octet, bitBegin)

	o:Set(bitCount, value)
	o:Set(bitCount, value)

	LuaUnit.assertEquals(tostring(buf), x)
end

function BufferWriterTest:TestSet_WithNumberAndNumber()
	TestSet_WithNumberAndNumber(1, 1, 8, 0xaa, "\170\170\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(8, 5, 8, 0xaa, "\069\040\033\230\056\208\019\167\170\090\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(1, 1, 32, 0xaa, "\170\000\000\000\170\000\000\000\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(1, 1, 32, 0xaaaaaaaa, "\170\170\170\170\170\170\170\170\190\084\102\207\052\233\012\108")
end

local function TestSet_WithNumberAndNumber_WhereNotCanHas(a, octet, bitBegin, bitCount, value)
	local buf = Buffer.New(a)
	local o = BufferWriter.New(buf, octet, bitBegin)

	LuaUnit.assertError(function ()
		o:Set(bitCount, value)
		o:Set(bitCount, value)
	end)
end

function BufferWriterTest:TestSet_WithNumberAndNumber_WhereNotCanHas()
	TestSet_WithNumberAndNumber_WhereNotCanHas(nil, 1, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 9, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 8, 2, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 8, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 7, 2, 8, 0x0)
end

local function TestSet_WithNumberAndNumberAndBoolean(octet, bitBegin, bitCount, value, x)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet, bitBegin)

	o:Set(bitCount, value, true)
	o:Set(bitCount, value, true)

	LuaUnit.assertEquals(tostring(buf), x)
end

function BufferWriterTest:TestSet_WithNumberAndNumberAndBoolean()
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 8, 0xaa, "\170\170")
	TestSet_WithNumberAndNumberAndBoolean(8, 5, 8, 0xaa, "\000\000\000\000\000\000\000\160\170\010")
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 32, 0xaa, "\170\000\000\000\170\000\000\000")
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 32, 0xaaaaaaaa, "\170\170\170\170\170\170\170\170")
end

local function TestSetSignify_WithNumberAndNumber(octet, bitBegin, bitCount, value, x)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet, bitBegin)

	o:SetSignify(bitCount, value, true)

	LuaUnit.assertEquals(tostring(buf), x)
end

function BufferWriterTest:TestSetSignify_WithNumberAndNumber()
	TestSetSignify_WithNumberAndNumber(1, 1, 8, 127, "\255")
	TestSetSignify_WithNumberAndNumber(1, 1, 8, -128, "\000")
	TestSetSignify_WithNumberAndNumber(1, 1, 8, 0, "\128")
	TestSetSignify_WithNumberAndNumber(1, 1, 1, 0, "\001")
	TestSetSignify_WithNumberAndNumber(1, 1, 2, 1, "\003")
	TestSetSignify_WithNumberAndNumber(1, 1, 1, -1, "\000")
	TestSetSignify_WithNumberAndNumber(1, 1, 32, (1 << 31) - 1, "\255\255\255\255")
	TestSetSignify_WithNumberAndNumber(1, 1, 32, -(1 << 31), "\000\000\000\000")
	TestSetSignify_WithNumberAndNumber(1, 5, 8, 127, "\240\015")
	TestSetSignify_WithNumberAndNumber(1, 5, 8, -128, "\000\000")
	TestSetSignify_WithNumberAndNumber(1, 5, 8, 0, "\000\008")
	TestSetSignify_WithNumberAndNumber(1, 8, 1, 0, "\128")
	TestSetSignify_WithNumberAndNumber(1, 8, 2, 1, "\128\001")
	TestSetSignify_WithNumberAndNumber(1, 8, 1, -1, "\000")
end

local function TestSetSignify_WithNumberAndNumber_WhereNotCanHas(octet, bitBegin, bitCount, value)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet, bitBegin)

	LuaUnit.assertError(function ()
		o:SetSignify(bitCount, value, true)
	end)
end

function BufferWriterTest:TestSetSignify_WithNumberAndNumber_WhereNotCanHas()
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 1, 7, 127)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 1, 7, -128)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 1, 1, 1)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 5, 7, 127)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 5, 7, -128)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 5, 1, 1)
end

local function TestSetNillify_WithNumberAndNumber(octet, bitBegin, bitCount, value, x)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet, bitBegin)

	o:SetNillify(bitCount, value, true)

	LuaUnit.assertEquals(tostring(buf), x)
end

function BufferWriterTest:TestSetNillify_WithNumberAndNumber()
	TestSetNillify_WithNumberAndNumber(1, 1, 8, nil, "\000")
	TestSetNillify_WithNumberAndNumber(1, 1, 8, 255, "\255")
end

local function TestSetBoolean_WithNumberAndNumber(octet, bitBegin, bitCount, value, x)
	local buf = Buffer.New()
	local o = BufferWriter.New(buf, octet, bitBegin)

	o:SetBoolean(bitCount, value, true)

	LuaUnit.assertEquals(tostring(buf), x)
end

function BufferWriterTest:TestSetBoolean_WithNumberAndNumber()
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, false, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, true, "\001")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, nil, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, 0, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, -1, "\001")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, "", "\001")
	TestSetBoolean_WithNumberAndNumber(1, 1, 8, false, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 8, true, "\001")
end

local function TestReserve_WithNumber(a, octet, bitBegin, bitCount, x)
	local buf = Buffer.New(a)
	local o = BufferWriter.New(buf, octet, bitBegin)

	o:Reserve(bitCount)

	LuaUnit.assertEquals(tostring(buf), x)
end

function BufferWriterTest:TestReserve_WithNumber()
	TestReserve_WithNumber(nil, 0, 1, 8, "")
	TestReserve_WithNumber(nil, 1, 1, 8, "\000")
	TestReserve_WithNumber(nil, 8, 1, 8, "\000\000\000\000\000\000\000\000")
	TestReserve_WithNumber(nil, 9, 1, 8, "\000\000\000\000\000\000\000\000\000")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 0, 1, 8, "")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, 1, 8, "\069")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 8, 1, 8, "\069\040\033\230\056\208\019\119")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 9, 1, 8, "\069\040\033\230\056\208\019\119\190")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 17, 1, 8, "\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108\000")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 8, 5, 8, "\069\040\033\230\056\208\019\119\014")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, 1, 0, "")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 2, 1, 0, "\069")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, 1, 72, "\069\040\033\230\056\208\019\119\190")
end

return BufferWriterTest
