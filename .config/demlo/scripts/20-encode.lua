------------------------------------
--	ENCODING
------------------------------------

-- demlo script
-- Set format (container) and codec parameters. 
-- Format is kept if supported.

-- TODO: Check which format supports video streams. (E.g. for embedded covers.)

-- set output format
for f, settings in pairs(encoding_map) do
	if input.format.format_name:match(f) then
		output.format = settings.format or input.format.format_name
		output.parameters = settings.parameters
		debug("found format: " .. output.format)
		break
	end
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
	ext = "m4a"
elseif output.format == 'aac' then
	-- wrap raw aac streams in an mp4 container
	output.format = 'mp4'
	ext = "m4a"
end
