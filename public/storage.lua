local tracker = require('resty.fastdfs.tracker')
local storage = require('resty.fastdfs.storage')
local socket = require('socket')

module('storage', package.seeall)

---- 存储文件
---- server_cfg = { host = 'xx',port = 80 }
---- binary       file binary
---- format     file_type 'amr' or mp3

---- return values table 
---- origin_res["group_name"],origin_res["file_name"]

local function save_into_store(server_cfg, binary, format)
	-->> get store
	local tk = tracker:new()
	tk:set_timeout(3000)
	local ok, err = tk:connect(server_cfg)
	if not ok then
		only.log('E', string.format('connect tracker error:%s',err))
		return nil
	end
	local res, err = tk:query_storage_store()
	if not res then
		only.log('E', string.format('query storage error:%s',err))
		return nil
	end
	local st = storage:new()
	st:set_timeout(3000)
	local ok, err = st:connect(res)
	if not ok then
		only.log('E', string.format('connect storage error:%s',err))
		return nil
	end
	local res, err = st:upload_by_buff(binary, format)
	if not res then
		only.log('E', string.format('upload error:%s',err))
		return nil
	end
	return res
end

---- server_cfg = { host = 'xx',port = 80 }
---- return values table 
---- origin_res["group_name"],origin_res["file_name"]
function save_file_to_store(server_cfg, binary, format, file_name)
	if not binary or #binary < 1 then return false ,'binary is nil' end 
	if not format then format = 'amr' end
	if not file_name then file_name= string.format("%d",socket.gettime() * 100000000) end
	local res = save_into_store(server_cfg, binary, format)
	if not res then
		only.log('E', string.format('fastdfs failed:%s',file_name))
		return false,'DFS server is error'
	end
	return true,res
end

---- detail 
---- public function  save_file_to_store
---- args
---- 1: server_cfg is table include host port 
----        test = {host = 'www.host.com',port = 80}
---- 2: binary
----        binary is file binary 
---- 3: format
----        format is mp3 or amr (current default amr)
---- 4: file_name
----        file_name is current file name 

