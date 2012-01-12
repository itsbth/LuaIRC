--#/bin/env lua
local lunit = require 'lunit'

package.path = package.path .. ";../lib/?.lua"

require 'net.protocol.testhttp'

lunit.loadrunner("lunit-console")
lunit.run()