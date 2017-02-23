
local jTTS = require("jTTS")

print(jTTS)


local ok, buffer , length = jTTS.text2voice("172.16.21.167:3000","长沙市有17人,您所在的幺零零八六频道有317人在线","47FF1422-796F-427F-8408-EC5FD3367729",9,5)
print(ok)
if not ok then
	print(ok)
	print("xxx" .. buffer)
	print("yyy" .. length)
else
	print("====succed====")
	print(#buffer)
	print(length)

	local tmp_file_name = string.format("/tmp/%s.wav",os.time())
	local f = assert(io.open(tmp_file_name,'w'))
	if  f then
		f:write(buffer)
		f:close()
	end

	print(tmp_file_name)

end

