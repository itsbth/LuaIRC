--- Irc protocol
local socket = require 'socket'
local ustring = require 'util.string'
local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local setmetable = setmetatable

module 'net.protocol.irc'

function parse(msg)
	local out = {}
	local pos = 0
	if msg:sub(1, 1) == ':' then
		pos = msg:find(' ')
		out.from = msg:sub(1, pos - 1)
		local oldpos = pos
		pos = msg:find(' ', oldpos + 1)
		
		-- The command comes directly after
		out.name = msg:sub(oldpos + 1, pos - 1)
	else
		-- If there isn't a username,
		-- read the command
		pos = msg:find(' ')
		out.name = msg:sub(1, pos - 1)					
	end
	
	-- If the next character is a ':',
	-- read the rest of the arguments
	if msg:sub(pos + 1, pos + 1) == ':' then
		out.arg = msg:sub(pos + 2)
	else
		-- If the we don't have any arguments yet,
		-- read the recipient
		oldpos = pos
		pos = msg:find(' ', pos + 1)
		out.to = msg:sub(oldpos + 1, pos - 1)
		
		-- Most messages ends here
		if msg:sub(pos + 1, pos + 1) == ':' then
			out.arg = msg:sub(pos + 2)
		else
			-- Some commands, like KICK, takes a second user
			
			-- Check if there is an equals sign there
			if msg:sub(pos + 1, pos + 1) == '=' then
				-- Increase pos by two to skip it
				pos = pos + 2
				out.eq = true
			else
				out.eq = false
			end
			oldpos = pos
			pos = msg:find(' ', pos + 1)
			out.nick = msg:sub(oldpos + 1, pos - 1)
			if msg:sub(pos + 1, pos + 1) == ':' then
				out.arg = msg:sub(pos + 2)
			end						
		end					
	end
	return out
end

function create(tbl)
	local str = ""
	if tbl.from then
		str = str .. ":" .. tbl.from .. " "
	end
	if tbl.name then
		str = str .. tbl.name .. " "
	end
	-- str += "#{@name} " unless @name == nil
	if out.to then
		str = str .. out.to .. " "
	end
	-- str += "#{@to} " unless @to == nil
	if out.eq then
		str = str .. "= "
	end
	-- str += "= " if @eq # COMBO BREAKER
	if out.nick then
		str = str .. out.nick .. " "
	end
	-- str += "#{@nick} " unless @nick == nil
	if out.arg then
		str = str .. ":" .. out.arg
	end
	-- str += ":#{@arg}" unless @arg == nil
	return str
end

function altCreate(tbl)
	return ustring.build(tbl, "from", ":%s ", "name", "%s ", "to", "%s ", "eq", "= ", "nick", "%s ", "arg", ":%s")
end