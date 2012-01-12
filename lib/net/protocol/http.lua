local utable = require 'util.table'
local ustring = require 'util.string'
local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local tonumber = tonumber
local setmetatable = setmetatable
local assert = assert
local print = print

module 'net.protocol.http'

local http_mt = {}
http_mt.__index = http_mt

function http_mt:parse(line)
    print("-line- " .. self.mode .. " -line-")
	if self.mode == 'response' then
		-- Assume this is the first run, so we should have the status here.
		local _, _, ver, statusNum, statusString = line:find "HTTP/(%d\.%d) (%d+) (.+)"
		ver, statusNum = tonumber(ver), tonumber(statusNum)
		assert(ver == 1.1, "only http version 1.1 is supported")
		local mode
		if statusNum >= 100 and statusNum < 200 then
			mode = 'response'
		else
			mode = 'headers'
		end
		self.version, self.status, self.headers, self.body, self.mode = ver, {statusNum, statusString}, {}, nil, mode
	elseif self.mode == 'headers' then
		if line == "" then
            print "Changing mode to body"
			self.mode = 'body'
			self.receiveArg = {'*a'}
		elseif line:sub(1, 1):match("%s") then
			assert(self.lastHeader, "multiline header found but no name stored")
			self.headers[self.lastHeader] = self.headers[self.lastHeader] .. ustring.trim(line)
		else
			local _, _, header, value = line:find "([%a-]+):(.+)"
			value = ustring.trim(value)
			self.headers[header] = value
			self.lastHeader = header
		end
	elseif self.mode == 'body' then
        print "Body here"
		self.body = self.body .. line
	end
end

function new()
	return setmetatable({mode = 'response', receiveArg = {'*l'}, body = ''}, http_mt)
end