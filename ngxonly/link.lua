module(..., package.seeall)

OWN_POOL = {
	redis = {},
	mysql = {},
	mongodb = {},
	http = {},
	tcp = {},
	zmq = {},
}


OWN_DIED = {
	redis = {},
	mysql = {},
	http = {},
	tcp = {},
}

for _,v in pairs(require('cfg').OWN_LINK or {}) do
	print(v)
	local one = require(v)
	table.foreach( one["OWN_POOL"]["redis"] or {}, function(i, v) OWN_POOL["redis"][i] = v end )
	table.foreach( one["OWN_POOL"]["mysql"] or {}, function(i, v) OWN_POOL["mysql"][i] = v end )
	table.foreach( one["OWN_POOL"]["mongodb"] or {}, function(i, v) OWN_POOL["mongodb"][i] = v end )
	table.foreach( one["OWN_POOL"]["http"] or {}, function(i, v) OWN_POOL["http"][i] = v end )
	table.foreach( one["OWN_POOL"]["tcp"] or {}, function(i, v) OWN_POOL["tcp"][i] = v end )
	table.foreach( one["OWN_POOL"]["zmq"] or {}, function(i, v) OWN_POOL["zmq"][i] = v end )
	table.foreach( one["OWN_DIED"]["redis"] or {}, function(i, v) OWN_DIED["redis"][i] = v end )
	table.foreach( one["OWN_DIED"]["mysql"] or {}, function(i, v) OWN_DIED["mysql"][i] = v end )
	table.foreach( one["OWN_DIED"]["http"] or {}, function(i, v) OWN_DIED["http"][i] = v end )
	table.foreach( one["OWN_DIED"]["tcp"] or {}, function(i, v) OWN_DIED["tcp"][i] = v end )
end

setmetatable(_M, { __index = _M })
