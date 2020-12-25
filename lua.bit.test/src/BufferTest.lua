local LuaUnit = require("luaunit")

local Buffer = require("Buffer")

local BufferTest = {}

local function TestNew()
	local o = Buffer.New()

	LuaUnit.assertEquals(tostring(o), "")
end

function BufferTest:TestNew()
	TestNew()
end

local function TestNew_WithString(a)
	local o = Buffer.New(a)

	LuaUnit.assertEquals(tostring(o), a)
end

function BufferTest:TestNew_WithString()
	TestNew_WithString("")
	TestNew_WithString("\000")
	TestNew_WithString("\255")
	TestNew_WithString("\069")
	TestNew_WithString("\000\000\000\000\000\000\000\000")
	TestNew_WithString("\255\255\255\255\255\255\255\255")
	TestNew_WithString("\069\040\033\230\056\208\019\119")
	TestNew_WithString("\000\000\000\000\000\000\000\000\000")
	TestNew_WithString("\255\255\255\255\255\255\255\255\255")
	TestNew_WithString("\069\040\033\230\056\208\019\119\190")
	TestNew_WithString("\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000")
	TestNew_WithString("\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255")
	TestNew_WithString("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestNew_WithString(string.rep("\000", 16 * 1024))
	TestNew_WithString(string.rep("\255", 16 * 1024))
end

local function TestNormalize(index, begin, x, y)
	local o, p = Buffer.Normalize(index, begin)

	LuaUnit.assertEquals(o, x)
	LuaUnit.assertEquals(p, y)
end

function BufferTest:TestNormalize()
	TestNormalize(1, 1, 1, 1)
	TestNormalize(1, 9, 2, 1)
	TestNormalize(1, 17, 3, 1)
end

local function TestIncrement(index, begin, count, x, y)
	local o, p = Buffer.Increment(index, begin, count)

	LuaUnit.assertEquals(o, x)
	LuaUnit.assertEquals(p, y)
end

function BufferTest:TestIncrement()
	TestIncrement(1, 1, 1, 1, 2)
	TestIncrement(1, 1, 8, 2, 1)
	TestIncrement(1, 1, 16, 3, 1)
end

local function TestGet_WithNumber(index, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertEquals(o:Get(index), x)
end

function BufferTest:TestGet_WithNumber()
	TestGet_WithNumber(1, 0x45)
	TestGet_WithNumber(8, 0x77)
	TestGet_WithNumber(9, 0xbe)
end

local function TestGet_WithNumber_WhereNotValid(index)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Get(index)
	end)
end

function BufferTest:TestGet_WithNumber_WhereNotValid()
	TestGet_WithNumber_WhereNotValid(0)
	TestGet_WithNumber_WhereNotValid(math.maxinteger)
	TestGet_WithNumber_WhereNotValid(1.1)
end

local function TestGet_WithNumberAndNumberAndNumber(index, begin, count, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertEquals(o:Get(index, begin, count), x)
end

function BufferTest:TestGet_WithNumberAndNumberAndNumber()
	TestGet_WithNumberAndNumberAndNumber(1, 1, 8, 0x45)
	TestGet_WithNumberAndNumberAndNumber(8, 5, 8, 0xe7)
	TestGet_WithNumberAndNumberAndNumber(1, 1, 64, 0x7713d038e6212845)
end

local function TestGet_WithNumberAndNumberAndNumber_WhereNotValid(index, begin, count)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Get(index, begin, count)
	end)
end

function BufferTest:TestGet_WithNumberAndNumberAndNumber_WhereNotValid()
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(0, 1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(math.maxinteger, 1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 0)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 65)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestSet_WithNumber(index, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	o:Set(index, value)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestSet_WithNumber()
	TestSet_WithNumber(1, 0xaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumber(8, 0xaa, "\069\040\033\230\056\208\019\170\190\084\102\207\052\233\012\108")
	TestSet_WithNumber(9, 0xaa, "\069\040\033\230\056\208\019\119\170\084\102\207\052\233\012\108")
	TestSet_WithNumber(1, 0xaaaaaaaaaaaaaaaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumber(8, 0xaaaaaaaaaaaaaaaa, "\069\040\033\230\056\208\019\170\190\084\102\207\052\233\012\108")
	TestSet_WithNumber(9, 0xaaaaaaaaaaaaaaaa, "\069\040\033\230\056\208\019\119\170\084\102\207\052\233\012\108")
end

local function TestSet_WithNumber_WhereNotValid(index)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Set(index)
	end)
end

function BufferTest:TestSet_WithNumber_WhereNotValid()
	TestSet_WithNumber_WhereNotValid(0)
	TestSet_WithNumber_WhereNotValid(math.maxinteger)
	TestSet_WithNumber_WhereNotValid(1.1)
end

local function TestSet_WithNumberAndNumberAndNumber(index, begin, count, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	o:Set(index, begin, count, value)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestSet_WithNumberAndNumberAndNumber()
	TestSet_WithNumberAndNumberAndNumber(1, 1, 8, 0xaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumber(8, 5, 8, 0xaa, "\069\040\033\230\056\208\019\167\186\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumber(1, 1, 64, 0xaa, "\170\000\000\000\000\000\000\000\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumber(1, 1, 8, 0xaaaaaaaaaaaaaaaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumber(8, 5, 8, 0xaaaaaaaaaaaaaaaa, "\069\040\033\230\056\208\019\167\186\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumber(1, 1, 64, 0xaaaaaaaaaaaaaaaa, "\170\170\170\170\170\170\170\170\190\084\102\207\052\233\012\108")
end

local function TestSet_WithNumberAndNumberAndNumber_WhereNotValid(index, begin, count)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Set(index, begin, count)
	end)
end

function BufferTest:TestSet_WithNumberAndNumberAndNumber_WhereNotValid()
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(0, 1, 8)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(math.maxinteger, 1, 8)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 0)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 65)
	TestSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestReserve_WithNumber(a, index, x)
	local o = Buffer.New(a)

	o:Reserve(index)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestReserve_WithNumber()
	TestReserve_WithNumber(nil, 0, "")
	TestReserve_WithNumber(nil, 1, "\000")
	TestReserve_WithNumber(nil, 8, "\000\000\000\000\000\000\000\000")
	TestReserve_WithNumber(nil, 9, "\000\000\000\000\000\000\000\000\000")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 0, "")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, "\069")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 8, "\069\040\033\230\056\208\019\119")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 9, "\069\040\033\230\056\208\019\119\190")
	TestReserve_WithNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 17, "\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108\000")
end

local function TestReserve_WithNumber_WhereNotValid(index)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Reserve(index)
	end)
end

function BufferTest:TestReserve_WithNumber_WhereNotValid()
	TestReserve_WithNumber_WhereNotValid(-1)
	TestReserve_WithNumber_WhereNotValid(1.1)
end

local function TestReserve_WithNumberAndNumberAndNumber(a, index, begin, count, x)
	local o = Buffer.New(a)

	o:Reserve(index, begin, count)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestReserve_WithNumberAndNumberAndNumber()
	TestReserve_WithNumberAndNumberAndNumber(nil, 0, 1, 8, "")
	TestReserve_WithNumberAndNumberAndNumber(nil, 1, 1, 8, "\000")
	TestReserve_WithNumberAndNumberAndNumber(nil, 8, 1, 8, "\000\000\000\000\000\000\000\000")
	TestReserve_WithNumberAndNumberAndNumber(nil, 9, 1, 8, "\000\000\000\000\000\000\000\000\000")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 0, 1, 8, "")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, 1, 8, "\069")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 8, 1, 8, "\069\040\033\230\056\208\019\119")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 9, 1, 8, "\069\040\033\230\056\208\019\119\190")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 17, 1, 8, "\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108\000")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 8, 5, 8, "\069\040\033\230\056\208\019\119\014")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, 1, 0, "")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 2, 1, 0, "\069")
	TestReserve_WithNumberAndNumberAndNumber("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1, 1, 72, "\069\040\033\230\056\208\019\119\190")
end

local function TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(index, begin, count)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Reserve(index, begin, count)
	end)
end

function BufferTest:TestReserve_WithNumberAndNumberAndNumber_WhereNotValid()
	TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(-1, 1, 8)
	TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestMetamethodLen(a, index)
	local o = Buffer.New(a)

	o:Reserve(index)

	LuaUnit.assertEquals(#o, index)
	LuaUnit.assertEquals(#o, #tostring(o))
end

function BufferTest:TestMetamethodLen()
	TestMetamethodLen(nil, 0)
	TestMetamethodLen(nil, 1)
	TestMetamethodLen(nil, 8)
	TestMetamethodLen(nil, 9)
	TestMetamethodLen("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 0)
	TestMetamethodLen("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 1)
	TestMetamethodLen("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 8)
	TestMetamethodLen("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 9)
	TestMetamethodLen("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108", 17)
end

return BufferTest
