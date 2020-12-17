local LuaUnit = require("luaunit")

local BufferTest = require("BufferTest")

local luaUnit = LuaUnit.LuaUnit.new()

luaUnit:runSuiteByInstances({
	{"BufferTest", BufferTest}})

os.exit((luaUnit.result.notSuccessCount == nil) or (luaUnit.result.notSuccessCount == 0))
