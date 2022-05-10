local LuaUnit = require("luaunit")

local BufferTest = require("BufferTest")
local BufferReaderTest = require("BufferReaderTest")
local BufferWriterTest = require("BufferWriterTest")

local luaUnit = LuaUnit.LuaUnit.new()

luaUnit:runSuiteByInstances({
	{"BufferTest", BufferTest},
	{"BufferReaderTest", BufferReaderTest},
	{"BufferWriterTest", BufferWriterTest}})

os.exit((luaUnit.result.notSuccessCount == nil) or (luaUnit.result.notSuccessCount == 0))
