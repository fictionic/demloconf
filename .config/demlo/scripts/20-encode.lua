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
for _, mapping in ipairs(encoding_map) do
	f, settings = mapping[1], mapping[2]
	if input.format.format_name:match(f) then
		output.format = settings.format or input.format.format_name
		output.parameters = settings.parameters
		debug("found format: " .. output.format)
		found_format = true
		break
	end
end
if not found_format then
	debug("WARNING: no matching format in encoding_map")
end

if output.format == 'mov,mp4,m4a,3gp,3g2,mj2' then
	-- Help ffprobe to pin down the MPEG-4 subformat.
	if i.major_brand == '3gp4' then
		output.format = '3gp'
	elseif i.major_brand == '3g2a' then
		output.format = '3g2'
	elseif i.major_brand == 'qt  ' then
		output.format = 'mov'
	else
		-- ???? FFmpeg does not support m4a. Use mp4 instead.
		output.format = 'mp4'
	end
	extension = 'm4a'
elseif output.format == 'aac' then
	-- wrap raw aac streams in an mp4 container
	output.format = 'mp4'
	extension = 'm4a'
else
	extension = output.format
end
