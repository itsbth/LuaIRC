local socket = require 'socket'
local reactor = require 'net.reactor'
local url = require 'socket.url'
local utable = require 'util.table'
local proto = require 'net.protocol.irc'
local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local setmetatable = setmetatable
local assert = assert
local print = print

module 'net.client.irc'

local config = {
	respondToPing = true,
	user = {"LuaBot", "N/A", "N/A"},
	nick = {"LuaBot", "LuaBot_", "LuaBot__"},
}

local irc_cb_mt = {}

irc_cb_mt.__index = irc_cb_mt

function irc_cb_mt:onReceive(skt, data)
	print("DATA: " .. data)
	local res = proto.parse(data)
	-- XXX: UGLY
	self.conn.socket = skt
	self.conn:onCommand(res)
end

function irc_cb_mt:onClosed(skt)
	self.conn:OnConnectionClosed()
end

local irc_conn_mt = {}
irc_conn_mt.__index = irc_conn_mt

function irc_conn_mt:connect()
	self.conn = setmetatable({conn = self}, irc_cb_mt)
	local sock = socket.connect(self.config.host, self.config.port)
	reactor.addClient(sock, self.conn)
	sock:send("USER LuaBot foo bar :Foo Bar\r\n")
	sock:send("NICK ITSBOT_Lua_v2\r\n")
end

function irc_conn_mt:sendMessage(to, message)
	self.conn.socket:send(proto.create{name = "PRIVMSG", to = to, arg = message})
end

function irc_conn_mt:sendNotice(to, message)
    self.conn.socket:send(proto.create{name = "NOTICE", to = to, arg = message})
end

function irc_conn_mt:joinChannel(channel)
    self.conn.socket:send(proto.create{name = "JOIN"})
end

function irc_conn_mt:partChannel(channel)

end

function irc_conn_mt:setMode(mode, user)

end

function irc_conn_mt:onCommand(cmd)
	-- TODO: Clean up
	if cmd.name == "PING" then
		self.socket:send("PONG " .. cmd.arg .. "\r\n")
		print("Sent pong")
	end
end

function irc_conn_mt:onConnectionClosed()

end

function connect(tbl, cb)
	local out = setmetatable({cb = cb, config = tbl}, irc_conn_mt)
	out:connect()
	return out
end
