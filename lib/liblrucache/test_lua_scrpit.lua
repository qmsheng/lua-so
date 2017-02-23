
local cache = require("lrucache")

print(cache)


base_address = nil

local function init_cache()
	local MAX_CACHE_SIZE = 2
	local MAX_VALUE_SIZE = 128
	base_address , err = lrucache.init(MAX_CACHE_SIZE,MAX_VALUE_SIZE)
	if not base_address then
		print(string.format("[****]lrucache init failed! %s", err))
		return nil
	end
	print(string.format("base_address:[%s]" , base_address) )
end

local function setValue(key,val)
	if not base_address then
		return nil
	end

	local ok, ret = lrucache.setValue(base_address, key , val, #val)
	if not ok then
		print(ok, ret )
	end

end

local function getValue( key, val )
	if not base_address then
		return nil,nil
	end
	local ok, val = lrucache.getValue(base_address, key )
	if not ok then
		print( string.format("[****]get value--failed key:%s , err [%s]",key, val) )
	end
	return ok , val 
end

local  function get_cache_info(  )
	if not base_address then
		return nil,nil
	end

	local ok, size, err = lrucache.getSize(base_address)
	local ok, capacity, err = lrucache.getCapacity(base_address);
	print(string.format("====size:%s , capacity:%s", size, capacity))
end

local function setValueEx( key )
	setValue(key,key)
end

local function test_cache(  )
	init_cache()


	for i = 1 , 40 do
		setValueEx(tostring(i))
	end
	
	setValueEx(tostring(1))
	setValueEx(tostring(4))
	setValueEx(tostring(5))
	setValueEx(tostring(6))
	setValueEx(tostring(7))
	setValueEx(tostring(8))
	setValueEx(tostring(8))
	setValueEx(tostring(4))
	setValueEx(tostring(5))
	setValueEx(tostring(16))
	setValueEx(tostring(10))
	setValueEx(tostring(8))
	
	get_cache_info()

	for i = 1 , 40 do
		local ok, val = getValue(tostring(i))
		if ok then
			print(string.format("ok:%s key:%s val:%s", ok, i, val))
		end
	end

	

end

test_cache()


