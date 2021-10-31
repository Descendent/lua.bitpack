local LuaUnit = require("luaunit")

local BufferTest = require("BufferTest")
local ReaderTest = require("ReaderTest")
local WriterTest = require("WriterTest")

local luaUnit = LuaUnit.LuaUnit.new()

luaUnit:runSuiteByInstances({
	{"BufferTest", BufferTest},
	{"ReaderTest", ReaderTest},
	{"WriterTest", WriterTest}})

os.exit((luaUnit.result.notSuccessCount == nil) or (luaUnit.result.notSuccessCount == 0))
