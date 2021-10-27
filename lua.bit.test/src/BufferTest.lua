local LuaUnit = require("luaunit")

local Buffer = require("Buffer")

local BufferTest = {}

local function New(str)
	local buf = Buffer.New()

	if str == nil then
		return buf
	end

	buf:Reserve(#str)

	local index = 1
	local begin = 1
	for i = 1, #str do
		buf:Set(index, begin, 8, string.byte(str, i))
		index, begin = Buffer.Increment(index, begin, 8)
	end

	return buf
end

local function ToString(buf)
	local str = {}

	local index = 1
	local begin = 1
	for i = 1, #buf do
		str[i] = string.char(buf:Get(index, begin, 8))
		index, begin = Buffer.Increment(index, begin, 8)
	end

	return table.concat(str)
end

local function TestNew()
	local o = Buffer.New()

	LuaUnit.assertEquals(ToString(o), "")
end

function BufferTest:TestNew()
	TestNew()
end

local function TestNew_WithString(a, x)
	local o = Buffer.New(a)

	LuaUnit.assertEquals(ToString(o), x)
end

function BufferTest:TestNew_WithString()
	TestNew_WithString("", "")
	TestNew_WithString("00", "\x00")
	TestNew_WithString("H5", "\x86")
	TestNew_WithString("Hed", "\x86\x4F")
	TestNew_WithString("Helj", "\x86\x4F\xD2")
	TestNew_WithString("Hello", "\x86\x4F\xD2\x6F")
	TestNew_WithString("HelloWe", "\x86\x4F\xD2\x6F\xB5")
	TestNew_WithString("HelloWoi", "\x86\x4F\xD2\x6F\xB5\x59")
	TestNew_WithString("HelloWork", "\x86\x4F\xD2\x6F\xB5\x59\xF7")

	-- https://github.com/zeromq/rfc/blob/master/src/spec_32.c
	TestNew_WithString("HelloWorld", "\x86\x4F\xD2\x6F\xB5\x59\xF7\x5B")
	TestNew_WithString("JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6", "\x8E\x0B\xDD\x69\x76\x28\xB9\x1D\x8F\x24\x55\x87\xEE\x95\xC5\xB0\x4D\x48\x96\x3F\x79\x25\x98\x77\xB4\x9C\xD9\x06\x3A\xEA\xD3\xB7")
end

local function TestNew_WithString_WhereNotValid(a)
	local o

	LuaUnit.assertError(function ()
		o = Buffer.New(a)
	end)
end

function BufferTest:TestNew_WithString_WhereNotValid()
	TestNew_WithString_WhereNotValid("0")
	TestNew_WithString_WhereNotValid("0000\000")
	TestNew_WithString_WhereNotValid("0000\031")
	TestNew_WithString_WhereNotValid("0000\128")
	TestNew_WithString_WhereNotValid("0000\255")
	TestNew_WithString_WhereNotValid("0000 ")
	TestNew_WithString_WhereNotValid("0000\"")
	TestNew_WithString_WhereNotValid("0000\'")
	TestNew_WithString_WhereNotValid("0000,")
	TestNew_WithString_WhereNotValid("0000;")
	TestNew_WithString_WhereNotValid("0000\\")
	TestNew_WithString_WhereNotValid("0000_")
	TestNew_WithString_WhereNotValid("0000`")
	TestNew_WithString_WhereNotValid("0000|")
	TestNew_WithString_WhereNotValid("0000~")
	TestNew_WithString_WhereNotValid("0000\127")
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
	TestIncrement(1, 1, 0, 1, 1)
	TestIncrement(1, 1, 1, 1, 2)
	TestIncrement(1, 1, 8, 2, 1)
	TestIncrement(1, 1, 16, 3, 1)
	TestIncrement(1, 1, -1, 0, 8)
	TestIncrement(1, 2, -1, 1, 1)
	TestIncrement(2, 1, -8, 1, 1)
	TestIncrement(3, 1, -16, 1, 1)
end

local function TestCanGet_WithNumber(a, index, x)
	local o = New(a)

	LuaUnit.assertEquals(o:CanGet(index), x)
end

function BufferTest:TestCanGet_WithNumber()
	TestCanGet_WithNumber(nil, 1, false)
	TestCanGet_WithNumber("\000\000\000\000\000\000\000\000", 8, true)
	TestCanGet_WithNumber("\000\000\000\000\000\000\000\000", 9, false)
end

local function TestCanGet_WithNumber_WhereNotValid(index)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:CanGet(index)
	end)
end

function BufferTest:TestCanGet_WithNumber_WhereNotValid()
	TestCanGet_WithNumber_WhereNotValid(0)
	TestCanGet_WithNumber_WhereNotValid(1.1)
end

local function TestCanGet_WithNumberAndNumberAndNumber(a, index, begin, count, x)
	local o = New(a)

	LuaUnit.assertEquals(o:CanGet(index, begin, count), x)
end

function BufferTest:TestCanGet_WithNumberAndNumberAndNumber()
	TestCanGet_WithNumberAndNumberAndNumber(nil, 1, 1, 8, false)
	TestCanGet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 8, 1, 8, true)
	TestCanGet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 9, 1, 8, false)
	TestCanGet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 8, 5, 8, false)
	TestCanGet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 1, 1, 64, true)
end

local function TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(index, begin, count)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:CanGet(index, begin, count)
	end)
end

function BufferTest:TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid()
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(0, 1, 8)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 0)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 65)
	TestCanGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestCanSet_WithNumber(a, index, x)
	local o = New(a)

	LuaUnit.assertEquals(o:CanSet(index), x)
end

function BufferTest:TestCanSet_WithNumber()
	TestCanSet_WithNumber(nil, 1, false)
	TestCanSet_WithNumber("\000\000\000\000\000\000\000\000", 8, true)
	TestCanSet_WithNumber("\000\000\000\000\000\000\000\000", 9, false)
end

local function TestCanSet_WithNumber_WhereNotValid(index)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:CanSet(index)
	end)
end

function BufferTest:TestCanSet_WithNumber_WhereNotValid()
	TestCanSet_WithNumber_WhereNotValid(0)
	TestCanSet_WithNumber_WhereNotValid(1.1)
end

local function TestCanSet_WithNumberAndNumberAndNumber(a, index, begin, count, x)
	local o = New(a)

	LuaUnit.assertEquals(o:CanSet(index, begin, count), x)
end

function BufferTest:TestCanSet_WithNumberAndNumberAndNumber()
	TestCanSet_WithNumberAndNumberAndNumber(nil, 1, 1, 8, false)
	TestCanSet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 8, 1, 8, true)
	TestCanSet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 9, 1, 8, false)
	TestCanSet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 8, 5, 8, false)
	TestCanSet_WithNumberAndNumberAndNumber("\000\000\000\000\000\000\000\000", 1, 1, 64, true)
end

local function TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(index, begin, count)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:CanSet(index, begin, count)
	end)
end

function BufferTest:TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid()
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(0, 1, 8)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1.1, 1, 8)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 0, 8)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 9, 8)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1.1, 8)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 0)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 65)
	TestCanSet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestGet_WithNumber(index, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertEquals(o:Get(index), x)
end

function BufferTest:TestGet_WithNumber()
	TestGet_WithNumber(1, 0x45)
	TestGet_WithNumber(8, 0x77)
	TestGet_WithNumber(9, 0xbe)
end

local function TestGet_WithNumber_WhereNotValid(index)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Get(index)
	end)
end

function BufferTest:TestGet_WithNumber_WhereNotValid()
	TestGet_WithNumber_WhereNotValid(0)
	TestGet_WithNumber_WhereNotValid(math.maxinteger) -- Out of range
	TestGet_WithNumber_WhereNotValid(1.1)
end

local function TestGet_WithNumberAndNumberAndNumber(index, begin, count, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertEquals(o:Get(index, begin, count), x)
end

function BufferTest:TestGet_WithNumberAndNumberAndNumber()
	TestGet_WithNumberAndNumberAndNumber(1, 1, 8, 0x45)
	TestGet_WithNumberAndNumberAndNumber(8, 5, 8, 0xe7)
	TestGet_WithNumberAndNumberAndNumber(1, 1, 64, 0x7713d038e6212845)
end

local function TestGet_WithNumberAndNumberAndNumber_WhereNotValid(index, begin, count)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Get(index, begin, count)
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
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 65)
	TestGet_WithNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1)
end

local function TestSet_WithNumberAndNumber(index, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	o:Set(index, value)

	LuaUnit.assertEquals(ToString(o), x)
end

function BufferTest:TestSet_WithNumberAndNumber()
	TestSet_WithNumberAndNumber(1, 0xaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(8, 0xaa, "\069\040\033\230\056\208\019\170\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(9, 0xaa, "\069\040\033\230\056\208\019\119\170\084\102\207\052\233\012\108")
end

local function TestSet_WithNumberAndNumber_WhereNotValid(index, value)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Set(index, value)
	end)
end

function BufferTest:TestSet_WithNumberAndNumber_WhereNotValid()
	TestSet_WithNumberAndNumber_WhereNotValid(0, 0x0)
	TestSet_WithNumberAndNumber_WhereNotValid(math.maxinteger, 0x0) -- Out of range
	TestSet_WithNumberAndNumber_WhereNotValid(1.1, 0x0)
	TestSet_WithNumberAndNumber_WhereNotValid(1, 0x1ff)
end

local function TestSet_WithNumberAndNumberAndNumberAndNumber(index, begin, count, value, x)
	-- 45 28 21 e6 38 d0 13 77 be 54 66 cf 34 e9 0c 6c
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	o:Set(index, begin, count, value)

	LuaUnit.assertEquals(ToString(o), x)
end

function BufferTest:TestSet_WithNumberAndNumberAndNumberAndNumber()
	TestSet_WithNumberAndNumberAndNumberAndNumber(1, 1, 8, 0xaa, "\170\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumberAndNumber(8, 5, 8, 0xaa, "\069\040\033\230\056\208\019\167\186\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumberAndNumber(1, 1, 64, 0xaa, "\170\000\000\000\000\000\000\000\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumberAndNumberAndNumber(1, 1, 64, 0xaaaaaaaaaaaaaaaa, "\170\170\170\170\170\170\170\170\190\084\102\207\052\233\012\108")
end

local function TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(index, begin, count, value)
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Set(index, begin, count, value)
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
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 65, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 1.1, 0x0)
	TestSet_WithNumberAndNumberAndNumberAndNumber_WhereNotValid(1, 1, 8, 0x1ff)
end

local function TestReserve_WithNumber(a, index, x)
	local o = New(a)

	o:Reserve(index)

	LuaUnit.assertEquals(ToString(o), x)
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
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

	LuaUnit.assertError(function ()
		o:Reserve(index)
	end)
end

function BufferTest:TestReserve_WithNumber_WhereNotValid()
	TestReserve_WithNumber_WhereNotValid(-1)
	TestReserve_WithNumber_WhereNotValid(1.1)
end

local function TestReserve_WithNumberAndNumberAndNumber(a, index, begin, count, x)
	local o = New(a)

	o:Reserve(index, begin, count)

	LuaUnit.assertEquals(ToString(o), x)
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
	local o = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")

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
	local o = New(a)

	o:Reserve(index)

	LuaUnit.assertEquals(#o, index)
	LuaUnit.assertEquals(#o, #ToString(o))
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

local function TestMetamethodTostring(a, x)
	local o = New(a)

	LuaUnit.assertEquals(tostring(o), x)
end

function BufferTest:TestMetamethodTostring()
	TestMetamethodTostring(nil, "")
	TestMetamethodTostring("", "")
	TestMetamethodTostring("\x00", "00")
	TestMetamethodTostring("\x86", "H5")
	TestMetamethodTostring("\x86\x4F", "Hed")
	TestMetamethodTostring("\x86\x4F\xD2", "Helj")
	TestMetamethodTostring("\x86\x4F\xD2\x6F", "Hello")
	TestMetamethodTostring("\x86\x4F\xD2\x6F\xB5", "HelloWe")
	TestMetamethodTostring("\x86\x4F\xD2\x6F\xB5\x59", "HelloWoi")
	TestMetamethodTostring("\x86\x4F\xD2\x6F\xB5\x59\xF7", "HelloWork")

	-- https://github.com/zeromq/rfc/blob/master/src/spec_32.c
	TestMetamethodTostring("\x86\x4F\xD2\x6F\xB5\x59\xF7\x5B", "HelloWorld")
	TestMetamethodTostring("\x8E\x0B\xDD\x69\x76\x28\xB9\x1D\x8F\x24\x55\x87\xEE\x95\xC5\xB0\x4D\x48\x96\x3F\x79\x25\x98\x77\xB4\x9C\xD9\x06\x3A\xEA\xD3\xB7", "JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6")
end

return BufferTest
