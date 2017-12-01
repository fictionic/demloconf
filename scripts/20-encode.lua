------------------------------------
--	ENCODING
------------------------------------

debug([[//===============\\]])
debug([[|| 20-encode.lua ||]])
debug([[\\===============//]])

-- demlo script
-- Set format (container) and codec parameters. 
-- Format is kept if supported.

-- TODO: Check which format supports video streams. (E.g. for embedded covers.)

-- set output format
local found_format = false
for _, mapping in ipairs(settings.encode.map) do
	format_re, encoder_setting = mapping[1], mapping[2]
	if input.format.format_name:match(format_re) then
		output.format = encoder_setting.format or input.format.format_name
		debug("found format: " .. output.format)
		output.parameters = encoder_setting.parameters
		debug("found parameters: " .. to_str(output.parameters))
		if settings.encode.override_parameters then
			output.parameters = settings.encode.override_parameters
			debug("overriding parameters: " .. to_str(output.parameters))
		elseif settings.encode.append_paremeters then
			output.parameters = table_concat(encoder_setting.parameters, settings.encode.append_paremeters)
			debug("appending to parameters: " .. to_str(output.parameters))
		end
		found_format = true
		break
	end
end
if not found_format then
	debug("WARNING: no matching format in encoding_map")
end

if output.format:match("(mov,mp4,m4a,3gp,3g2,mj2|aac)") then
	if output.format == 'mov,mp4,m4a,3gp,3g2,mj2' then
		debug("narrowing down mp4 subformat")
		debug("major brand: " .. i.major_brand)
		-- Help ffprobe to pin down the MPEG-4 subformat.
		if i.major_brand == '3gp4' then
			output.format = '3gp'
		elseif i.major_brand == '3g2a' then
			output.format = '3g2'
		elseif i.major_brand == 'qt  ' then
			output.format = 'mov'
		else -- i.major_brand == 'M4A '
			-- FFmpeg does not support m4a. Use mp4 instead.
			output.format = 'mp4'
		end
	elseif output.format == 'aac' then
		-- wrap raw aac streams in an mp4 container
		debug("wrapping aac in m4a container")
		output.format = 'mp4'
	end
	debug("computed output format: " .. output.format)
end
