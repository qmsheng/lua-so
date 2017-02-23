local cfg = require('cfg')
-->>|
for _,v in pairs(cfg["OWN_INIT"] or {}) do
	require(v)
end

-->>|
local redis_pool = require('redis_pool_api')
local mysql_pool = require('mysql_pool_api')
if cfg["OWN_INFO"]["POOLS"] then
	redis_pool.init()
	mysql_pool.init()
end
-->>|set at last
local only = require('only')
only.initlogs()
