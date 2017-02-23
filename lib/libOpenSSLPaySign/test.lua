
libPaySign = require("libOpenSSLPaySign")


-- print(libPaySign)

-- print(libPaySign.openssl_pkey_get_public_encrypt)


local pem_buf = ""
local data = "xxxx"

local fx = io.open("/data/tools/test_openssl/public_key.pem",'r')
if not fx then
	print("pem open failed!")
	return
end

pem_buf = fx:read('*all')


local ok , ret   = libPaySign.openssl_pkey_get_public_encrypt(pem_buf,#pem_buf, data,#data)

print( ok )
print( ret )
print( #ret )
