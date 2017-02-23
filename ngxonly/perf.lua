local socket = require('socket')
local only = require('only')
local APP_CFG = require('cfg')

module('perf', package.seeall)


EXEC_PERF_LIST = {}
EXEC_STEP_LIST = {}
EXEC_BASE_TIME = 0


function init()
	if APP_CFG["OWN_INFO"]["PERF"] then
		EXEC_PERF_LIST = {}
		EXEC_STEP_LIST = {}
		EXEC_BASE_TIME = socket.gettime()
	end
end

function cost( name, real )
	if APP_CFG["OWN_INFO"]["PERF"] then
		local msg
		local t = socket.gettime()
		if real then
			if not EXEC_PERF_LIST[ name ] then
				EXEC_PERF_LIST[ name ] = t
				return
			else
				EXEC_STEP_LIST[ name ] = (EXEC_STEP_LIST[ name ] or 0) + 1
				msg = string.format("||%s<=%d=>%f||", name, EXEC_STEP_LIST[ name ], t - EXEC_PERF_LIST[ name ])
				EXEC_PERF_LIST[ name ] = nil
			end
		else
			EXEC_STEP_LIST[ name ] = (EXEC_STEP_LIST[ name ] or 0) + 1
			msg = string.format("||%s<=%d=>%f||", name, EXEC_STEP_LIST[ name ], t - (EXEC_PERF_LIST[ name ] or EXEC_BASE_TIME))
			EXEC_PERF_LIST[ name ] = t
		end

		only.makelogs("performance", 'S', "%s", tostring(msg))
	end
end
------------------------------------------------------------------------------------------------
function bind( name1, name2 )
	if APP_CFG["OWN_INFO"]["PERF"] then
		local t = socket.gettime()
		EXEC_PERF_LIST[ name1 ] = t
		EXEC_PERF_LIST[ name2 ] = t
	end
end

function over( name )
	if APP_CFG["OWN_INFO"]["PERF"] then
		local t = socket.gettime()
		EXEC_STEP_LIST[ name ] = (EXEC_STEP_LIST[ name ] or 0) + 1
		local msg = string.format("||%s<=%d=>%f||", name, EXEC_STEP_LIST[ name ], t - EXEC_PERF_LIST[ name ])

		only.makelogs("performance", 'S', "%s", tostring(msg))
	end
end
