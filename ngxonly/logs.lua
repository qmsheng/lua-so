
module("logs", package.seeall)

LOG_FILE_TIME = {}
LOG_FILE_HAND = {}
LOG_FILE_DATA = {}

function setup(name)
	-->> set log file by first time
	if not LOG_FILE_TIME[ name ] then
		LOG_FILE_TIME[ name ] = os.date("%Y%m")
		local f
		if ngx.var.LOG_FILE_PATH then
			f = ngx.var.LOG_FILE_PATH .. "access_" .. name .. "_" .. LOG_FILE_TIME[ name ] .. ".log"
		else
			f = "/tmp/" .. "access_" .. name .. "_" .. LOG_FILE_TIME[ name ] .. ".log"
		end
		LOG_FILE_HAND[ name ] = assert(io.open(f, "a"))
	end
	-->> update log file by after time
	if LOG_FILE_TIME[ name ] ~= os.date("%Y%m") then
		LOG_FILE_HAND[ name ]:close()
		LOG_FILE_TIME[ name ] = os.date("%Y%m")
		local f
		if ngx.var.LOG_FILE_PATH then
			f = ngx.var.LOG_FILE_PATH .. "access_" .. name .. "_" .. LOG_FILE_TIME[ name ] .. ".log"
		else
			f = "/tmp/" .. "access_" .. name .. "_" .. LOG_FILE_TIME[ name ] .. ".log"
		end
		LOG_FILE_HAND[ name ] = assert(io.open(f, "a"))
	end
end

function push(key, val)
	if not LOG_FILE_DATA[ key ] then
		LOG_FILE_DATA[ key ] = {}
	end
	table.insert(LOG_FILE_DATA[ key ], val)
end

function pull()
	local info = {}
	for k,v in pairs(LOG_FILE_DATA) do
		info[ k ] = table.concat( v, "" )
		LOG_FILE_DATA[ k ] = nil
	end
	return info
end
