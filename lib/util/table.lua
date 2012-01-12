local ipairs, pairs = ipairs, pairs
local table, math, string = table, math, string
local setmetable = setmetatable
local assert = assert
local type = type

module 'util.table'

function merge(tbl1, tbl2)
	for k,v in pairs(tbl2) do
		if not tbl1[k] then
			tbl1[k] = v
		end
	end
	return tbl1
end

function mergeRecursive(tbl1, tbl2)
	for k,v in pairs(tbl2) do
		if type(v) == 'table' and type(tbl1[k]) == 'table' then
			mergeRecursive(tbl1[k], v)
		elseif not tbl1[k] then
			tbl1[k] = v
		end
	end
	return tbl1
end