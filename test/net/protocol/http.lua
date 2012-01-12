local lunit = require 'lunit'
local http = require 'net.protocol.http'
local ipairs, pairs = ipairs, pairs
local getmetatable = getmetatable

module('test.net.protocol.http', lunit.testcase)

function constructorTest()
	assert_function(http.new)
	local o = http.new()
	assert_not_nil(o)
	local mt = getmetatable(o)
	assert_table(mt)
	assert_function(mt.parse)
	assert_equal(mt, mt.__index)
end

function parseTest()
	local tab = {
		"HTTP/1.1 200 OK",
		"Cookie: foo=bar;1234",
		"X-Powered-By: Acme PSW -2.5",
		"X-Foo: Bar",
		"X-Multiline: Foo,",
		"\tBar",
		"",
	}
	local tab_expected = {
		Cookie = "foo=bar;1234",
		["X-Powered-By"] = "Acme PSW -2.5",
		["X-Foo"] = "Bar",
		["X-Multiline"] = "Foo,Bar",
	}
	local body = [[
	<h1>N/A</h1>
	]]
	local tbl = http.new()
	for k,v in ipairs(tab) do
		tbl:parse(v)
	end
	tbl:parse(body)
	assert_equal(200, tbl.status[1], "status number")
	assert_equal("OK", tbl.status[2], "status text")
	for k,v in pairs(tab_expected) do
		assert_equal(v, tbl.headers[k], "header")
	end
	assert_equal(body, tbl.body, "body")
end