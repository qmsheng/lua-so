package.path = '/data/nginx/open/lib/?.lua;' .. package.path
package.cpath = '/data/nginx/open/lib/?.so;' .. package.cpath

local lua_imageMagick = require("lua_imageMagick")

print(lua_imageMagick)


local function test_readImageSize()
	local ok, width,height= lua_imageMagick.readImageSize("logo-01.png")
	print(ok)
	print("w." .. width)
	print("h." .. height)
end

local function test_pitcureWaterMark()
	local logo_x,logo_y = 100,100
	local text = "道客FM\n道客WM"
	--local text = "道客FM"
	local fontsize 

	if string.find(text,"\n") then 
		font_x = logo_x +width+5
		font_y = logo_y +height/2.7
	    fontsize = 8
	else 
		font_x = logo_x +width+5
		font_y = logo_y +height/1.5
	    fontsize = 12
	end
	--(char *src, char *logo, char *result, char *text, int logo_x, int logo_y, int text_x, int text_y, char *font, double fontSize,char *fontColor )
	local ok = lua_imageMagick.pictureWaterMark("test.png","logo-01.png","desc.png",text,logo_x,logo_y,font_x,font_y,"SIMHEI.TTF",fontsize)
	print(ok)
end

test_readImageSize()
test_pitcureWaterMark()