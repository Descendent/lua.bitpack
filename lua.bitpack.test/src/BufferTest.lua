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

local function TestNormalize(octet, bitBegin, x, y)
	local o, p = Buffer.Normalize(octet, bitBegin)

	LuaUnit.assertEquals(o, x)
	LuaUnit.assertEquals(p, y)
end

function BufferTest:TestNormalize()
	TestNormalize(1, 1, 1, 1)
	TestNormalize(1, 9, 2, 1)
	TestNormalize(1, 17, 3, 1)
end

local function TestIncrement(octet, bitBegin, bitCount, x, y)
	local o, p = Buffer.Increment(octet, bitBegin, bitCount)

	LuaUnit.assertEquals(o, x)
	LuaUnit.assertEquals(p, y)
end

function BufferTest:TestIncrement()
	TestIncrement(1, 1, 0, 1, 1)
	TestIncrement(1, 1, 1, 1, 2)
	TestIncrement(1, 1, 8, 2, 1)
	TestIncrement(1, 1, 16, 3, 1)
	TestIncrement(1, 1, -1, 0, 8)
	TestIncrement(1, 2, -1, 1, 1)
	TestIncrement(2, 1, -8, 1, 1)
	TestIncrement(3, 1, -16, 1, 1)
end

local function TestCanHas_WithNumber(a, octet, x)
	local o = Buffer.New(a)

	LuaUnit.assertEquals(o:CanHas(octet), x)
end

function BufferTest:TestCanHas_WithNumber()
	TestCanHas_WithNumber(nil, 1, false)
	TestCanHas_WithNumber("\000\000\000\000\000\000\000\000", 8, true)
	TestCanHas_WithNumber("\000\000\000\000\000\000\000\000", 9, false)
end

local function TestCanHas_WithNumber_WhereNotValid(octet)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:CanHas(octet)
	end)
end

function BufferTest:TestCanHas_WithNumber_WhereNotValid()
	TestCanHas_WithNumber_WhereNotValid(0)
	TestCanHas_WithNumber_WhereNotValid(1.1)
end

local function TestCanHas_WithNumberAndNumberAndNumber(a, octet, bitBegin, bitCount, x)
	local o = Buffer.New(a)

	LuaUnit.assertEquals(o:CanHas(octet, bitBegin, bitCount), x)
end

function BufferTest:TestCanHas_WithNumberAndNumberAndNumber()
	TestCanHas_WithNumberAndNumberAndNumber(nil, 1, 1, 8, false)
	TestCanHas_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 8, 1, 8, true)
	TestCanHas_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 9, 1, 8, false)
	TestCanHas_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 8, 5, 8, false)
	TestCanHas_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 1, 1, 64, true)
	TestCanHas_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000\000", 1, 1, 65, true)
end

local function TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(octet, bitBegin, bitCount)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:CanHas(octet, bitBegin, bitCount)
	end)
end

function BufferTest:TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid()
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(0, 1, 8)
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 0)
	TestCanHas_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestGet_WithNumber(octet, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertEquals(o:Get(octet), x)
end

function BufferTest:TestGet_WithNumber()
	TestGet_WithNumber(1, 0x45)
	TestGet_WithNumber(8, 0x77)
	TestGet_WithNumber(9, 0xbe)
end

local function TestGet_WithNumber_WhereNotValid(octet)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Get(octet)
	end)
end

function BufferTest:TestGet_WithNumber_WhereNotValid()
	TestGet_WithNumber_WhereNotValid(0)
	TestGet_WithNumber_WhereNotValid(math.maxinteger) -- Out of range
	TestGet_WithNumber_WhereNotValid(1.1)
end

local function TestGet_WithNumberAndNumberAndNumber(octet, bitBegin, bitCount, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertEquals(o:Get(octet, bitBegin, bitCount), x)
end

function BufferTest:TestGet_WithNumberAndNumberAndNumber()
	TestGet_WithNumberAndNumberAndNumber(1, 1, 8, 0x45)
	TestGet_WithNumberAndNumberAndNumber(8, 5, 8, 0xe7)
	TestGet_WithNumberAndNumberAndNumber(1, 1, 32, 0xe6212845)
end

local function TestGet_WithNumberAndNumberAndNumber_WhereNotValid(octet, bitBegin, bitCount)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Get(octet, bitBegin, bitCount)
	end)
end

function BufferTest:TestGet_WithNumberAndNumberAndNumber_WhereNotValid()
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(0, 1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(math.maxinteger, 1, 8) -- Out of range
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 0)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 33)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestSet_WithNumberAndNumber(octet, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	o:Set(octet, value)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestSet_WithNumberAndNumber()
	TestSet_WithNumberAndNumber(1, 0xaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(8, 0xaa, "\069\040\033\230\056\208\019\170\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(9, 0xaa, "\069\040\033\230\056\208\019\119\170\084\102\207\052\233\012\108")
end

local function TestSet_WithNumberAndNumber_WhereNotValid(octet, value)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Set(octet, value)
	end)
end

function BufferTest:TestSet_WithNumberAndNumber_WhereNotValid()
	TestSet_WithNumberAndNumber_WhereNotValid(0, 0x0)
	TestSet_WithNumberAndNumber_WhereNotValid(math.maxinteger, 0x0) -- Out of range
	TestSet_WithNumberAndNumber_WhereNotValid(1.1, 0x0)
	TestSet_WithNumberAndNumber_WhereNotValid(1, 0x1ff)
end

local function TestSet_WithNumberAndNumberAndNumberAndNumber(octet, bitBegin, bitCount, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	o:Set(octet, bitBegin, bitCount, value)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestSet_WithNumberAndNumberAndNumberAndNumber()
	TestSet_WithNumberAndNumberAndNumberAndNumber(1, 1, 8, 0xaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumberAndNumber(8, 5, 8, 0xaa, "\069\040\033\230\056\208\019\167\186\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumberAndNumber(1, 1, 32, 0xaa, "\170\000\000\000\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumberAndNumber(1, 1, 32, 0xaaaaaaaa, "\170\170\170\170\056\208\019\119\190\084\102\207\052\233\012\108")
end

local function TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(octet, bitBegin, bitCount, value)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Set(octet, bitBegin, bitCount, value)
	end)
end

function BufferTest:TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid()
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(0, 1, 8, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(math.maxinteger, 1, 8, 0x0) -- Out of range
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 0, 8, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 9, 8, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 0, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 33, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 8, 0x1ff)
end

local function TestReserve_WithNumber(a, octet, x)
	local o = Buffer.New(a)

	o:Reserve(octet)

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

local function TestReserve_WithNumber_WhereNotValid(octet)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Reserve(octet)
	end)
end

function BufferTest:TestReserve_WithNumber_WhereNotValid()
	TestReserve_WithNumber_WhereNotValid(-1)
	TestReserve_WithNumber_WhereNotValid(1.1)
end

local function TestReserve_WithNumberAndNumberAndNumber(a, octet, bitBegin, bitCount, x)
	local o = Buffer.New(a)

	o:Reserve(octet, bitBegin, bitCount)

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

local function TestReserve_WithNumberAndNumberAndNumber_WhereNotValid(octet, bitBegin, bitCount)
	local o = Buffer.New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Reserve(octet, bitBegin, bitCount)
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

local function TestMetamethodLen(a, octet)
	local o = Buffer.New(a)

	o:Reserve(octet)

	LuaUnit.assertEquals(#o, octet)
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
