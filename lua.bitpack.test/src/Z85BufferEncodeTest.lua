local LuaUnit = require("luaunit")

local Buffer = require("Buffer")
local Z85BufferEncode = require("Z85BufferEncode")

local Z85BufferEncodeTest = {}

local function TestNew_WithBufferAndString_WhereNotValid(a, b)
	local buf = Buffer.New(a)
	local o

	LuaUnit.assertError(function ()
		o = Z85BufferDecode.New(buf, b)
	end)
end

function Z85BufferEncodeTest:TestNew_WithBufferAndString_WhereNotValid()
	TestNew_WithBufferAndString_WhereNotValid(nil, {"\x00"})
end

local function TestGetRemaining(a, count, x)
	local buf = Buffer.New(a)
	local o = Z85BufferEncode.New(buf)

	for i = 1, #count do
		o:Process(count[i])
	end

	LuaUnit.assertEquals(o:GetRemaining(), x)
end

function Z85BufferEncodeTest:TestGetRemaining()
	TestGetRemaining("", {0}, 0)
	TestGetRemaining("\x00", {1}, 0)

	TestGetRemaining("\x86", {4}, 0)
	TestGetRemaining("\x86\x4F\xD2", {1}, 0)
	TestGetRemaining("\x86\x4F\xD2\x6F\xB5", {4}, 1)
	TestGetRemaining("\x86\x4F\xD2\x6F\xB5\x59\xF7", {1}, 3)

	TestGetRemaining("\x86\x4F\xD2\x6F\xB5", {1, 4}, 0)
	TestGetRemaining("\x86\x4F\xD2\x6F\xB5\x59\xF7", {1, 1}, 0)
end

local function TestProcess_WithNumber(a, count, x)
	local buf = Buffer.New(a)
	local o = Z85BufferEncode.New(buf)

	for i = 1, #count do
		o:Process(count[i])
	end

	LuaUnit.assertEquals(o:GetString(), x)
end

function Z85BufferEncodeTest:TestProcess_WithNumber()
	TestProcess_WithNumber("", {0}, "")
	TestProcess_WithNumber("\x00", {1}, "00")

	TestProcess_WithNumber("\x86", {1}, "H5")
	TestProcess_WithNumber("\x86\x4F", {2}, "Hed")
	TestProcess_WithNumber("\x86\x4F\xD2", {3}, "Helj")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F", {4}, "Hello")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5", {5}, "HelloWe")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5\x59", {6}, "HelloWoi")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5\x59\xF7", {7}, "HelloWork")

	-- https://github.com/zeromq/rfc/blob/master/src/spec_32.c
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5\x59\xF7\x5B", {8}, "HelloWorld")
	TestProcess_WithNumber("\x8E\x0B\xDD\x69\x76\x28\xB9\x1D\x8F\x24\x55\x87\xEE\x95\xC5\xB0\x4D\x48\x96\x3F\x79\x25\x98\x77\xB4\x9C\xD9\x06\x3A\xEA\xD3\xB7", {32}, "JTKVSB%%)wK0E.X)V>+}o?pNmC{O&4W4b!Ni{Lh6")

	TestProcess_WithNumber("", {1}, "")
	TestProcess_WithNumber("\x00", {0}, "")

	TestProcess_WithNumber("\x86", {4}, "H5")
	TestProcess_WithNumber("\x86\x4F\xD2", {1}, "Helj")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5", {8}, "HelloWe")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5\x59\xF7", {5}, "HelloWork")

	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5", {1, 4}, "HelloWe")
	TestProcess_WithNumber("\x86\x4F\xD2\x6F\xB5\x59\xF7", {1, 1}, "HelloWork")
end

return Z85BufferEncodeTest
