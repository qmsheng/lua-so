local APP_CFG = require('cfg')
local APP_LOGS = require('logs')
local lualog = require('lualog')

module('only', package.seeall)

LUA_FILE_INIT = false
--[[=================================LUA LOG FUNCTION=======================================]]--
local OWN_LOGLV = {
	D = {1, "[DEBUG]"       },
	I = {2, "[INFO]"        },
	W = {3, "[WARN]"	},
	F = {4, "[FAIL]"	},
	E = {5, "[ERROR]"       },
	S = {9, "[SYSTEM]"      },

	verbose = APP_CFG["OWN_INFO"]["LOGLV"],
}


function L_initlogs()
	LUA_FILE_INIT = true
end


function L_openlogs()
	APP_LOGS.setup( ngx.var.API_NAME )

	if APP_CFG["OWN_INFO"]["PERF"] then
		APP_LOGS.setup( "performance" )
	end
end


function L_makelogs(file, lv, fmt, ...)
	if LUA_FILE_INIT then
		local name = ngx["var"]["API_NAME"]
		local data = string.format("%s %s(%s)-->" .. tostring(fmt) .. "\n", ngx.get_now(), OWN_LOGLV[ lv ][2], (name or ""), ...)
		APP_LOGS.push(file, data)
	else
		local name = ""
		local data = string.format("%s %s(%s)-->" .. tostring(fmt) .. "\n", ngx.get_now(), OWN_LOGLV[ lv ][2], (name or ""), ...)
		io.stderr:write(data)
	end
end


function L_savelogs()
	local info = APP_LOGS.pull()
	for name,data in pairs( info or {} ) do
		if not APP_LOGS["LOG_FILE_TIME"][ name ] then
			io.stderr:write(data)
		else
			APP_LOGS["LOG_FILE_HAND"][ name ]:write(data .. '\n')
			APP_LOGS["LOG_FILE_HAND"][ name ]:flush()
		end
	end
end



function L_log(lv, fmt, ...)
	if lv ~= 'S' and OWN_LOGLV[ lv ][1] < OWN_LOGLV["verbose"] then return end

	local file = LUA_FILE_INIT and ngx["var"]["API_NAME"] or ""

	local ok, err = pcall(makelogs, file, lv, fmt, ...)
	if not ok then
		print(err)
		print(debug.traceback())
		assert(false, err .. "\n" .. debug.traceback())
	end
end


--[[=================================C LOG FUNCTION=======================================]]--
LOG_FILE_PATH = nil

function C_initlogs()
	lualog.setlevel( APP_CFG["OWN_INFO"]["LOGLV"] )
	
	LUA_FILE_INIT = true
end


function C_openlogs()
	if not LOG_FILE_PATH then
		LOG_FILE_PATH = ngx.var.LOG_FILE_PATH or "/tmp/"
		lualog.setpath( LOG_FILE_PATH )
	end
	
	if APP_CFG["OWN_INFO"]["PERF"] then
		lualog.open( "performance" )
	end

	lualog.open( ngx.var.API_NAME )
end


function C_makelogs(file, lv, fmt, ...)
	local name = LUA_FILE_INIT and ngx["var"]["API_NAME"] or ""
	
	local obj = lualog.pool["."]
	lualog.open( file )
	lualog.addinfo( name )
	lualog.write(lv, fmt, ...)
	lualog.pool["."] = obj
end


function C_savelogs()
end


C_log = lualog.write
--[[=================================ALL LOG FUNCTION=======================================]]--

initlogs = C_initlogs
openlogs = C_openlogs
makelogs = C_makelogs
savelogs = C_savelogs
log = C_log
