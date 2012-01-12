local lunit = require 'lunit'
local irc = require 'net.protocol.irc'
local ipairs, pairs = ipairs, pairs
local getmetatable = getmetatable

module('test.net.protocol.testhttp', lunit.testcase)
