-- -*- coding: utf-8 -*-
--
-- Puts raw PCM audio data into a Wave container.
-- (c) 2007 Alexandre Erwin Ittner <aittner@netuno.com.br>
--
-- This file is part of Lua-eSpeak and is distributed under the GNU GPL v2
-- or, at your option, any later version.
--
-- Documentation on Wave file format comes from: 
-- http://ccrma.stanford.edu/courses/422/projects/WaveFormat/
-- and http://technology.niagarac.on.ca/courses/ctec1631/WavFileFormat.html
--
-- TODO: Support to big-endian architectures.
-- BUGS: Assumes samples ending in a even byte boundary.
--

module("wave_api", package.seeall)

-- Sloooooooooooooooow ;)
local function number_to_ule(num, bytes)
	local str = "" -- No overhead with tables. 8 bytes will not stress the GC.
	for i = 1, bytes do
		str = str .. string.char(math.mod(num, 256))
		num = math.floor(num/256)
	end
	return str
end

local function number_to_u16le(num)
	return number_to_ule(num, 2)
end

local function number_to_u32le(num)
	return number_to_ule(num, 4)
end


--[[
0         4   ChunkID          Contains the letters "RIFF" in ASCII form
(0x52494646 big-endian form).
4         4   ChunkSize        36 + SubChunk2Size, or more precisely:
4 + (8 + SubChunk1Size) + (8 + SubChunk2Size)
This is the size of the rest of the chunk 
following this number.  This is the size of the 
entire file in bytes minus 8 bytes for the
two fields not included in this count:
ChunkID and ChunkSize.
8         4   Format           Contains the letters "WAVE"
(0x57415645 big-endian form).
]]

--[[
12        4   Subchunk1ID      Contains the letters "fmt "
(0x666d7420 big-endian form).
16        4   Subchunk1Size    16 for PCM.  This is the size of the
rest of the Subchunk which follows this number.
20        2   AudioFormat      PCM = 1 (i.e. Linear quantization)
Values other than 1 indicate some 
form of compression.
22        2   NumChannels      Mono = 1, Stereo = 2, etc.
24        4   SampleRate       8000, 44100, etc.
28        4   ByteRate         == SampleRate * NumChannels * BitsPerSample/8
32        2   BlockAlign       == NumChannels * BitsPerSample/8
The number of bytes for one sample including
all channels. I wonder what happens when
this number isn't an integer?
34        2   BitsPerSample    8 bits = 8, 16 bits = 16, etc.
2   ExtraParamSize   if PCM, then doesn't exist
X   ExtraParams      space for extra parameters

]]

--[[
36        4   Subchunk2ID      Contains the letters "data"
(0x64617461 big-endian form).
40        4   Subchunk2Size    == NumSamples * NumChannels * BitsPerSample/8
This is the number of bytes in the data.
You can also think of this as the size
of the read of the subchunk following this 
number.
44        *   Data             The actual sound data.
]]




function init(big_endian, format, num_channels, sample_rate, bits)
	local afp = { }
	setmetatable(afp, { __index = _M })

	afp.big_endian = big_endian     -- Not suported yet.
	afp.format = format             -- 1 = RAW PCM, etc.
	afp.num_channels = num_channels -- 1 = Mono, 2 = Stereo, etc.
	afp.sample_rate = sample_rate   -- Eg. 22050 Hz.
	afp.bits = bits                 -- Eg. 16

	afp.fsize = 0
	afp.fdata = { }

	return afp
end

function feed(afp, data)
	table.insert(afp.fdata, data)
	afp.fsize = afp.fsize + data:len()
end

function over(afp)
	--> update headers.
	local headers = {}
	--> Data Chunk
	table.insert( headers, 1, number_to_u32le(afp.fsize) )
	table.insert( headers, 1, "data" )
	afp.fsize = afp.fsize + 8
	--> Format Chunk
	table.insert( headers, 1, number_to_u16le(afp.bits) )
	table.insert( headers, 1, number_to_u16le(afp.num_channels * afp.bits / 8) )
	table.insert( headers, 1, number_to_u32le(afp.num_channels * afp.sample_rate * afp.bits / 8) )
	table.insert( headers, 1, number_to_u32le(afp.sample_rate) )
	table.insert( headers, 1, number_to_u16le(afp.num_channels) )
	table.insert( headers, 1, number_to_u16le(afp.format) )
	table.insert( headers, 1, number_to_u32le(16) )
	table.insert( headers, 1, "fmt " )
	afp.fsize = afp.fsize + 24
	--> RIFF WAVE Chunk
	table.insert( headers, 1, "WAVE" )
	table.insert( headers, 1, number_to_u32le(afp.fsize + 4) )
	table.insert( headers, 1, afp.big_endian and "RIFX" or "RIFF" )
	afp.fsize = afp.fsize + 12

	local data = table.concat(headers) .. table.concat(afp.fdata)
	return afp.fsize, data
end
