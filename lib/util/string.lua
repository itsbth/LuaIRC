local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local setmetable = setmetatable
local assert = assert

module 'util.string'

function build(tbl, ...)
	local out = ""
	for i = 1, #arg, 2 do
		if tbl[arg[i]] then
			out = out .. arg[i + 1]:format(tbl[arg[i]])
		end
	end
	return out
end

function trim(str, pat)
	pat = pat or "%s"
	return (str:gsub("^" .. pat .. "*(.-)" .. pat .. "*$", "%1"))
end

function rtrim(str, pat)
	pat = pat or "%s"
	return (str:gsub("^(.-)" .. pat .. "*$", "%1"))
end

function ltrim(str, pat)
	pat = pat or "%s"
	return (str:gsub("^" .. pat .. "*(.-)$", "%1"))
end