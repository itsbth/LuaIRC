package.path = package.path .. ";../lib/?.lua"

local http = require 'net.client.http'
local reactor = require 'net.reactor'

local flag = true

local rq = {
	url = "http://wiremod.com/",
	headers = {
		Connection = 'close',
		["User-Agent"] = "LuaIRC Alpha",
	},
}

local cb = {
	onStatus = function(self, n, s)
		print(n, s)
	end,
	onFinished = function(self, tbl)
		print(tbl.body)
		for k,v in pairs(tbl.headers) do
			print(k, v)
		end
		flag = false
        print "--- ---"
        for k,v in pairs(tbl) do
            print(k .. " =>")
            print(tostring(v))
        end
	end,
}

http.request(rq, cb)

while flag do
	reactor.step()
end
