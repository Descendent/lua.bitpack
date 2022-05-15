local LuaUnit = require("luaunit")

local BufferTest = require("BufferTest")
local BufferReaderTest = require("BufferReaderTest")
local BufferWriterTest = require("BufferWriterTest")
local Z85BufferEncodeTest = require("Z85BufferEncodeTest")
local Z85BufferDecodeTest = require("Z85BufferDecodeTest")

local luaUnit = LuaUnit.LuaUnit.new()

luaUnit:runSuiteByInstances({
	{"BufferTest", BufferTest},
	{"BufferReaderTest", BufferReaderTest},
	{"BufferWriterTest", BufferWriterTest},
	{"Z85BufferEncodeTest", Z85BufferEncodeTest},
	{"Z85BufferDecodeTest", Z85BufferDecodeTest}})

os.exit((luaUnit.result.notSuccessCount == nil) or (luaUnit.result.notSuccessCount == 0))
