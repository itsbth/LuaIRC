--- Reactor
local socket = require 'socket'
local utable = require 'util.table'
local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local unpack = unpack
local print = print
local error = error

module 'net.reactor'

local config = {
	-- Default config
	client = {
		receiveArg = {}, -- Arguments passed to skt:recv(), defaults to an empty table
		onReceive = function() end,
		onClose = function() end,
		onTimeout = function() end,
	},
}

local servers, clients, hooks = {}, {}, {}

local shouldRun = true

function setup(tbl)
	utable.mergerecursive(config, tbl)
end

function addServer(srv)
	-- NYI
end

function addClient(cli, tbl)
	cli:settimeout(0, 'b')	-- Make sure the socket is non-blocking
	utable.mergeRecursive(tbl, config.client)
	table.insert(clients, {cli, tbl})
end

function addHook(tbl)
	table.insert(hooks, tbl)
end

function start()
	shouldRun = true
end

function halt()
	shouldRun = false
end

function run()
	while shouldRun do
		step()
		runhooks()
	end
end

function step()
	for k,v in pairs(clients) do
		local res, err = v[1]:receive(unpack(v[2].receiveArg))
		if res then
			--print(res)
			v[2]:onReceive(v[1], res)
		else
			if err == 'closed' then
				v[2]:onClosed(v[1])
				table.remove(clients, k)
			elseif err == 'timeout' then
				v[2]:onTimeout(v[1])
			else
				if not v[2]:onError(v[1], err) then
					error("Internal socket error: " .. err)
				end
			end
		end
	end
end

function runhooks()
	for k,v in pairs(hooks) do
		v:onHook()
	end
end