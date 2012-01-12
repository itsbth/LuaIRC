package.path = package.path .. ";../lib/?.lua"

local irc = require 'net.client.irc'
local reactor = require 'net.reactor'

local flag = true

local rq = {
	host = "irc.gamesurge.net",
	port = 6667,
}

local cli = irc.connect(rq, {})

while flag do
	reactor.step()
end
