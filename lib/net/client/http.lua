local socket = require 'socket'
local reactor = require 'net.reactor'
local url = require 'socket.url'
local utable = require 'util.table'
local proto = require 'net.protocol.http'
local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local setmetatable = setmetatable
local assert = assert
local print, tostring = print, tostring

module 'net.client.http'

local config = {
	client = {
		port = 80,
		method = "GET",
		body = nil,
		headers = {
			Connection = "close", -- No keep-alive support yet
		},
		cookiejar = {
		
		},
	},
}

local http_cb_mt = {}

http_cb_mt.__index = http_cb_mt

function http_cb_mt:onReceive(skt, data)
    print("> " .. data)
	if self.redirected then
		return
	end
	self.protocol:parse(data)
	if self.protocol.status and not self.gotStatus then
		self.cb:onStatus(self.protocol.status[1], self.protocol.status[2])
		self.gotStatus = self.protocol.status[1] ~= 100
	elseif self.protocol.headers.Location then
		self.redirected = true
        print("Redirected to " .. self.protocol.headers.Location)
		self.request.url = self.protocol.headers.Location
		self.protocol = nil
		skt:close()
		request(self.request, self.cb)
	elseif self.protocol.mode == 'body' then
		--self.protocol.body = (self.protocol.body or '') .. data
	end
	if self.protocol then
		self.receiveArg = self.protocol.receiveArg
	end
end

function http_cb_mt:onClosed(skt)
	if not self.redirected then
		self.cb:onFinished(self.protocol)
	end
end

function request(tbl, cb)
	assert(tbl.url, "no URL given")
	utable.mergeRecursive(tbl, config.client)
	local dt = url.parse(tbl.url)
	local host = dt.host
	local port = dt.port or tbl.port
	tbl.headers.Host = host
	local obj = {request = tbl, cb = cb, receiveArg = {'*l'}, protocol = proto.new()}
	setmetatable(obj, http_cb_mt)
	local sock = socket.connect(host, port)
	reactor.addClient(sock, obj)
	sendRequest(sock, tbl)
end

function sendRequest(sock, tbl)
	local dt = url.parse(tbl.url)
	sock:send(("%s %s?%s HTTP/1.1\r\n"):format(tbl.method, dt.path, dt.query or ""))
	for k,v in pairs(tbl.headers) do
		sock:send(("%s: %s\r\n"):format(k, v))
	end
	sock:send("\r\n")
end