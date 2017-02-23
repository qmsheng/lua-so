local ngx = require('ngx')
local utils = require('utils')
local only = require('only')
local json = require("cjson")
local base = _G

module("cache")


function table_encode(this, T)
	local tb = {}
	for k,v in base.pairs(T) do
		local key,val
		if base.type(k) == "number" then		-->| because when json decode,type number will change type to string
			key = '<' .. base.tostring(k) .. '>'
		else					-->| if type(k) == "string" then
			key = k
		end
		if base.type(v) == "table" then
			val = this:table_encode(v)
		else
			val = v
		end
		tb[key] = val
	end
	return tb
end

function lua_encode(this, T)
	local tb = this:table_encode(T)
	local ok,ret = base.pcall(json.encode, tb)
	if not ok then
		only.log('S', base.string.format('LUA ENCODE |---> FAILED! | ERROR: %s', ret))
		return nil
	end
	return ret
end


function table_decode(this, T)
	local tb = {}
	for k,v in base.pairs(T) do
		local key,val
		if base.string.find(k, '^%<%d+%>$') then		-->| because when json decode,type number will change type to string
			key =  base.tonumber(base.string.sub(k, 2, -2))
		else
			key = k
		end
		if base.type(v) == "table" then
			val = this:table_decode(v)
		else
			val = v
		end
		tb[key] = val
	end
	return tb
end

function lua_decode(this, S)
	local ok,ret = base.pcall(json.decode, S)
	if not ok then
		only.log('S', base.string.format('LUA DECODE |---> FAILED! | ERROR: %s', ret))
		return nil
	end
	local tb = this:table_decode(ret)
	return tb
end



--<=========================================OPEN API=========================================>--
function set(this, name, tb)
	local store = ngx.shared.cache
	local val = this:lua_encode(tb)
	if not val then
		only.log('S', base.string.format('LUA ENCODE | NAME : %s |---> FAILED!', name))
		return false
	end

	local ok = store:set(name, val)
	return ok
end

function get(this, name)
	local store = ngx.shared.cache
	local str = store:get(name)
	local tb = this:lua_decode(str)
	return tb
end

function reset(this, name, tb)
	local ok = this:set(name, tb)
	return ok
end

function init(this, list)
	for i=1,#list do
		local ok = this:set(list[i], base.require(list[i]))
		if not ok then return false end
		only.log('S', base.string.format('LUA ENCODE | NAME : %s |---> SUCCESS!', list[i]))
	end
	return true
end
