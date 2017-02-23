#!/usr/bin/env lua
-- -*- coding: utf-8 -*-

-- Writes speech to a audio file.
-- (c) 2007 Alexandre Erwin Ittner <aittner@netuno.com.br>
-- Distributed under the GPL v2 or later.

local espeak = require("espeak")

module("espeak_api", package.seeall)


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



---->>>init first
local hz = espeak.Initialize(espeak.AUDIO_OUTPUT_SYNCHRONOUS, 0)

if espeak.SetVoiceByName("zh") ~= espeak.EE_OK then
	print("Failed to set default voice.")
	return 0,nil
end
---->>>

function tts( text )

	local afp = init(false, 1, 1, hz, 16)

	espeak.SetSynthCallback(function(wave, event)
		print(event.type)
		if event.type == espeak.EVENT_WORD
			or event.type == espeak.EVENT_SENTENCE
			or event.type == espeak.EVENT_END
			or event.type == espeak.EVENT_LIST_TERMINATED
			or event.type == espeak.EVENT_SAMPLERATE then
			afp:feed(wave)
		end
		return false    -- Do not stops the synthesis.
	end)

	espeak.Synth(text or "", 0, espeak.POS_CHARACTER, 0, nil)
	espeak.Synchronize()
	--espeak.Terminate()

	return afp:over()
end
