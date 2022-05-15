local LuaUnit = require("luaunit")

local Buffer = require("Buffer")
local Z85BufferDecode = require("Z85BufferDecode")

local Z85BufferDecodeTest = {}

local function TestNew_WithBufferAndString_WhereNotValid(a, b)
	local buf = Buffer.New(a)
	local o

	LuaUnit.assertError(function ()
		o = Z85BufferDecode.New(buf, b)
	end)
end

function Z85BufferDecodeTest:TestNew_WithBufferAndString_WhereNotValid()
	TestNew_WithBufferAndString_WhereNotValid("\x00", "")
	TestNew_WithBufferAndString_WhereNotValid(nil, "0")
end

local function TestGetRemaining(a, count, x)
	local buf = Buffer.New()
	local o = Z85BufferDecode.New(buf, a)

	for i = 1, #count do
		o:Process(count[i])
	end

	LuaUnit.assertEquals(o:GetRemaining(), x)
end

function Z85BufferDecodeTest:TestGetRemaining()
	TestGetRemaining("", {0}, 0)
	TestGetRemaining("00", {1}, 0)

	TestGetRemaining("H5", {5}, 0)
	TestGetRemaining("Helj", {1}, 0)
	TestGetRemaining("HelloWe", {5}, 2)
	TestGetRemaining("HelloWork", {1}, 4)

	TestGetRemaining("HelloWe", {1, 5}, 0)
	TestGetRemaining("HelloWork", {1, 1}, 0)
end

local function TestProcess_WithNumber(a, count, x)
	local buf = Buffer.New()
	local o = Z85BufferDecode.New(buf, a)

	for i = 1, #count do
		o:Process(count[i])
	end

	LuaUnit.assertEquals(tostring(o:GetBuffer()), x)
end

function Z85BufferDecodeTest:TestProcess_WithNumber()
	TestProcess_WithNumber("", {0}, "")
	TestProcess_WithNumber("00", {2}, "\x00")

	TestProcess_WithNumber("H5", {2}, "\x86")
	TestProcess_WithNumber("Hed", {3}, "\x86\x4F")
	TestProcess_WithNumber("Helj", {4}, "\x86\x4F\xD2")
	TestProcess_WithNumber("Hello", {5}, "\x86\x4F\xD2\x6F")
	TestProcess_WithNumber("HelloWe", {7}, "\x86\x4F\xD2\x6F\xB5")
	TestProcess_WithNumber("HelloWoi", {8}, "\x86\x4F\xD2\x6F\xB5\x59")
	TestProcess_WithNumber("HelloWork", {9}, "\x86\x4F\xD2\x6F\xB5\x59\xF7")

	-- https://github.com/zeromq/rfc/blob/master/src/spec_32.c
	TestProcess_WithNumber("HelloWorld", {10}, "\x86\x4F\xD2\x6F\xB5\x59\xF7\x5B")
	TestProcess_WithNumber("JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6", {40}, "\x8E\x0B\xDD\x69\x76\x28\xB9\x1D\x8F\x24\x55\x87\xEE\x95\xC5\xB0\x4D\x48\x96\x3F\x79\x25\x98\x77\xB4\x9C\xD9\x06\x3A\xEA\xD3\xB7")

	TestProcess_WithNumber("", {1}, "")
	TestProcess_WithNumber("00", {0}, "")

	TestProcess_WithNumber("H5", {5}, "\x86")
	TestProcess_WithNumber("Helj", {1}, "\x86\x4F\xD2")
	TestProcess_WithNumber("HelloWe", {10}, "\x86\x4F\xD2\x6F\xB5")
	TestProcess_WithNumber("HelloWork", {6}, "\x86\x4F\xD2\x6F\xB5\x59\xF7")

	TestProcess_WithNumber("HelloWe", {1, 5}, "\x86\x4F\xD2\x6F\xB5")
	TestProcess_WithNumber("HelloWork", {1, 1}, "\x86\x4F\xD2\x6F\xB5\x59\xF7")
end

local function TestProcess_WithNumber_WhereNotValid(a)
	local buf = Buffer.New()
	local o = Z85BufferDecode.New(buf, a)

	LuaUnit.assertError(function ()
		o:Process(5)
	end)
end

function Z85BufferDecodeTest:TestProcess_WithNumber_WhereNotValid()
	TestProcess_WithNumber_WhereNotValid("0000\000")
	TestProcess_WithNumber_WhereNotValid("0000\031")
	TestProcess_WithNumber_WhereNotValid("0000\128")
	TestProcess_WithNumber_WhereNotValid("0000\255")
	TestProcess_WithNumber_WhereNotValid("0000 ")
	TestProcess_WithNumber_WhereNotValid("0000\"")
	TestProcess_WithNumber_WhereNotValid("0000\'")
	TestProcess_WithNumber_WhereNotValid("0000,")
	TestProcess_WithNumber_WhereNotValid("0000;")
	TestProcess_WithNumber_WhereNotValid("0000\\")
	TestProcess_WithNumber_WhereNotValid("0000_")
	TestProcess_WithNumber_WhereNotValid("0000`")
	TestProcess_WithNumber_WhereNotValid("0000|")
	TestProcess_WithNumber_WhereNotValid("0000~")
	TestProcess_WithNumber_WhereNotValid("0000\127")
end

return Z85BufferDecodeTest
