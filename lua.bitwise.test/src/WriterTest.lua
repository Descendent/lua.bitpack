local LuaUnit = require("luaunit")

local Buffer = require("Buffer")

local WriterTest = {}

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

local function TestNew_WithBuffer()
	local buf = New()
	local o = buf:GetWriter()

	LuaUnit.assertEquals(o:GetIndex(), 1)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function WriterTest:TestNew_WithBuffer()
	TestNew_WithBuffer()
end

local function TestNew_WithBufferAndNumber(index)
	local buf = New()
	local o = buf:GetWriter(index)

	LuaUnit.assertEquals(o:GetIndex(), index)
	LuaUnit.assertEquals(o:GetBegin(), 1)
end

function WriterTest:TestNew_WithBufferAndNumber()
	TestNew_WithBufferAndNumber(1)
	TestNew_WithBufferAndNumber(8)
end

local function TestNew_WithBufferAndNumberAndNumber(index, begin)
	local buf = New()
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
	local buf = New("\069\040\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	local o = buf:GetWriter(index, begin)

	o:Set(count, value)
	o:Set(count, value)

	LuaUnit.assertEquals(ToString(buf), x)
end

function WriterTest:TestSet_WithNumberAndNumber()
	TestSet_WithNumberAndNumber(1, 1, 8, 0xaa, "\170\170\033\230\056\208\019\119\190\084\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(8, 5, 8, 0xaa, "\069\040\033\230\056\208\019\167\170\090\102\207\052\233\012\108")
	TestSet_WithNumberAndNumber(1, 1, 64, 0xaa, "\170\000\000\000\000\000\000\000\170\000\000\000\000\000\000\000")
	TestSet_WithNumberAndNumber(1, 1, 64, 0xaaaaaaaaaaaaaaaa, "\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170")
end

local function TestSet_WithNumberAndNumber_WhereNotCanHas(a, index, begin, count, value)
	local buf = New(a)
	local o = buf:GetWriter(index, begin)

	LuaUnit.assertError(function ()
		o:Set(count, value)
		o:Set(count, value)
	end)
end

function WriterTest:TestSet_WithNumberAndNumber_WhereNotCanHas()
	TestSet_WithNumberAndNumber_WhereNotCanHas(nil, 1, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 9, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 8, 2, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 8, 1, 8, 0x0)
	TestSet_WithNumberAndNumber_WhereNotCanHas("\000\000\000\000\000\000\000\000", 7, 2, 8, 0x0)
end

local function TestSet_WithNumberAndNumberAndBoolean(index, begin, count, value, x)
	local buf = New()
	local o = buf:GetWriter(index, begin)

	o:Set(count, value, true)
	o:Set(count, value, true)

	LuaUnit.assertEquals(ToString(buf), x)
end

function WriterTest:TestSet_WithNumberAndNumberAndBoolean()
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 8, 0xaa, "\170\170")
	TestSet_WithNumberAndNumberAndBoolean(8, 5, 8, 0xaa, "\000\000\000\000\000\000\000\160\170\010")
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 64, 0xaa, "\170\000\000\000\000\000\000\000\170\000\000\000\000\000\000\000")
	TestSet_WithNumberAndNumberAndBoolean(1, 1, 64, 0xaaaaaaaaaaaaaaaa, "\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170\170")
end

local function TestSetSignify_WithNumberAndNumber(index, begin, count, value, x)
	local buf = New()
	local o = buf:GetWriter(index, begin)

	o:SetSignify(count, value, true)

	LuaUnit.assertEquals(ToString(buf), x)
end

function WriterTest:TestSetSignify_WithNumberAndNumber()
	TestSetSignify_WithNumberAndNumber(1, 1, 8, 127, "\255")
	TestSetSignify_WithNumberAndNumber(1, 1, 8, -128, "\000")
	TestSetSignify_WithNumberAndNumber(1, 1, 8, 0, "\128")
	TestSetSignify_WithNumberAndNumber(1, 1, 1, 0, "\001")
	TestSetSignify_WithNumberAndNumber(1, 1, 2, 1, "\003")
	TestSetSignify_WithNumberAndNumber(1, 1, 1, -1, "\000")
	TestSetSignify_WithNumberAndNumber(1, 1, 64, (1 << 63) - 1, "\255\255\255\255\255\255\255\255")
	TestSetSignify_WithNumberAndNumber(1, 1, 64, -(1 << 63), "\000\000\000\000\000\000\000\000")
	TestSetSignify_WithNumberAndNumber(1, 5, 8, 127, "\240\015")
	TestSetSignify_WithNumberAndNumber(1, 5, 8, -128, "\000\000")
	TestSetSignify_WithNumberAndNumber(1, 5, 8, 0, "\000\008")
	TestSetSignify_WithNumberAndNumber(1, 8, 1, 0, "\128")
	TestSetSignify_WithNumberAndNumber(1, 8, 2, 1, "\128\001")
	TestSetSignify_WithNumberAndNumber(1, 8, 1, -1, "\000")
end

local function TestSetSignify_WithNumberAndNumber_WhereNotCanHas(index, begin, count, value)
	local buf = New()
	local o = buf:GetWriter(index, begin)

	LuaUnit.assertError(function ()
		o:SetSignify(count, value, true)
	end)
end

function WriterTest:TestSetSignify_WithNumberAndNumber_WhereNotCanHas()
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 1, 7, 127)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 1, 7, -128)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 1, 1, 1)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 5, 7, 127)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 5, 7, -128)
	TestSetSignify_WithNumberAndNumber_WhereNotCanHas(1, 5, 1, 1)
end

local function TestSetNillify_WithNumberAndNumber(index, begin, count, value, x)
	local buf = New()
	local o = buf:GetWriter(index, begin)

	o:SetNillify(count, value, true)

	LuaUnit.assertEquals(ToString(buf), x)
end

function WriterTest:TestSetNillify_WithNumberAndNumber()
	TestSetNillify_WithNumberAndNumber(1, 1, 8, nil, "\000")
	TestSetNillify_WithNumberAndNumber(1, 1, 8, 255, "\255")
end

local function TestSetBoolean_WithNumberAndNumber(index, begin, count, value, x)
	local buf = New()
	local o = buf:GetWriter(index, begin)

	o:SetBoolean(count, value, true)

	LuaUnit.assertEquals(ToString(buf), x)
end

function WriterTest:TestSetBoolean_WithNumberAndNumber()
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, false, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, true, "\001")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, nil, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, 0, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, -1, "\001")
	TestSetBoolean_WithNumberAndNumber(1, 1, 1, "", "\001")
	TestSetBoolean_WithNumberAndNumber(1, 1, 8, false, "\000")
	TestSetBoolean_WithNumberAndNumber(1, 1, 8, true, "\001")
end

return WriterTest
