------------------------------------
--	COVERS
------------------------------------

-- demlo script
-- Remove embedded covers. Convert to jpeg. Skip covers beyond quality threshold. Skip duplicates.

-- Even though FFmpeg makes a distinction between format (container) and codec,
-- this is not useful for covers.

-- Input format names are different from the output formats which use Go
-- nomenclature. Default output formats are 'gif', 'jpeg' and 'png'.

-- Demlo skips covers with no path. It copies covers with no parameters or no
-- format. It transcodes covers with non-default parameters and format.

-- Properties
local LIMIT_LOW = 0
local LIMIT_HIGH = COVER_LIMIT_HIGH or 20000

local dirname = output.path:match('^(.*)/') or '.'

local checksum_list = {}

local function to_jpeg(input_cover, stream, file, basename)
	stream = stream or 0
	basename = basename or 'cover'

	local id = file and tostring(file) or stream and 'stream ' .. tostring(stream) or 'online'

	local output_cover = {}
	output_cover.parameters = {}

	if input_cover.width < LIMIT_LOW or input_cover.height < LIMIT_LOW then
		debug('skip low quality cover: ' .. id  ..  ' ([' .. tostring(input_cover.width) .. 'x' .. tostring(input_cover.height) .. '] < [' .. tostring(LIMIT_LOW) .. 'x'  .. tostring(LIMIT_LOW) .. '])')
		return output_cover
	end

	if checksum_list[input_cover.checksum] then
		debug('skip duplicate cover: ' .. id ..  ' (checksum('.. checksum_list[input_cover.checksum] ..')=' .. input_cover.checksum  ..')')
		return output_cover
	end

	-- Skip future duplicates.
	checksum_list[input_cover.checksum] = id

	local max_ratio = math.max(input_cover.width / LIMIT_HIGH, input_cover.height / LIMIT_HIGH)
	if max_ratio > 1 then
		debug('down-scale big cover: ' .. id ..  ' ([' .. tostring(input_cover.width) .. 'x' .. tostring(input_cover.height) .. '] > [' .. tostring(LIMIT_HIGH) .. 'x'  .. tostring(LIMIT_HIGH) .. '])')
		output_cover.parameters[#output_cover.parameters+1] = '-s'
		output_cover.parameters[#output_cover.parameters+1] = math.floor(input_cover.width/max_ratio + 0.5) .. 'x' .. math.floor(input_cover.height/max_ratio + 0.5)

	elseif input_cover.format == 'jpeg' then
		-- Already in jpeg, do not convert.
		output_cover.parameters = nil
	else
		-- Convert to jpeg.
		output_cover.parameters[#output_cover.parameters+1] = '-c:' .. stream
		output_cover.parameters[#output_cover.parameters+1] = 'mjpeg'
	end

	output_cover.format = 'mjpeg'
	output_cover.path = dirname .. '/' .. basename .. '.jpg'

	return output_cover
end

for stream, input_cover in pairs(input.embeddedcovers) do
	-- Extract embedded covers.
	output.embeddedcovers[stream] = to_jpeg(input_cover, stream)

	-- Remove all embedded covers.
	output.parameters[#output.parameters+1] = '-vn'
end

-- analyze external covers
for file, input_cover in pairs(input.externalcovers) do
	local base_filename = file:match([[(.+)\..+]]):gsub("_", " "):lower()
	local new_base_filename
	local albumname, artistname 
	if output.tags['album'] then
		albumname = output.tags['album']:lower()
		if output.tags['artist'] then
			artistname = output.tags['artist']:lower()
		end
	end

	-- analyze filename to determine what kind of cover it is
	local cover_type
	---- front cover
	local front_cover_re_list = {
		"folder",
		"(front|(front )?cover)"
	}
	if albumname then
		front_cover_re_list[#front_cover_re_list+1] = albumname .. '( - (front|(front )?cover))?'
		front_cover_re_list[#front_cover_re_list+1] = albumname .. [[( \((front|(front )?cover)\))?]]
		front_cover_re_list[#front_cover_re_list+1] = albumname .. [[( \[(front|(front )?cover)\])?]]
		if artistname then
			front_cover_re_list[#front_cover_re_list+1] = artistname .. ' - ' .. albumname .. '( - (front|(front )?cover))?'
			front_cover_re_list[#front_cover_re_list+1] = artistname .. ' - ' .. albumname .. [[ (\((front|(front )?cover)\))?]]
			front_cover_re_list[#front_cover_re_list+1] = artistname .. ' - ' .. albumname .. [[ (\[(front|(front )?cover)\])?]]
		end
	end

	for _, re in ipairs(front_cover_re_list) do
		if base_filename:match(re) then
			cover_type = "front"
			break
		end
	end
	---- back cover
	if not cover_type then
		local back_cover_re_list = {
			"back cover",
			"back",
		}
		if albumname then
			back_cover_re_list[#back_cover_re_list+1] = albumname .. '( - (back|(back )?cover))?'
			back_cover_re_list[#back_cover_re_list+1] = albumname .. [[( \((back|(back )?cover)\))?]]
			back_cover_re_list[#back_cover_re_list+1] = albumname .. [[( \[(back|(back )?cover)\])?]]
			if artistname then
				back_cover_re_list[#back_cover_re_list+1] = artistname .. ' - ' .. albumname .. '( - (back|(back )?cover))?'
				back_cover_re_list[#back_cover_re_list+1] = artistname .. ' - ' .. albumname .. [[ (\((back|(back )?cover)\))?]]
				back_cover_re_list[#back_cover_re_list+1] = artistname .. ' - ' .. albumname .. [[ (\[(back|(back )?cover)\])?]]
			end
		end
		for _, re in ipairs(back_cover_re_list) do
			if base_filename:match(re) then
				cover_type = "back"
				break
			end
		end
	end
	-- other covers
	if not cover_type then
		cover_type = "other"
	end

	-- standardize file names
	if cover_type == "front" then
		new_base_filename = "cover"
	elseif cover_type == "back" then
		new_base_filename = "back"
	elseif cover_type == "other" then
		new_base_filename = base_filename
	end
	
	-- report findings
	if new_base_filename ~= base_filename then
		debug("found external cover: '" .. file .. "' -> '" .. new_base_filename .. ".jpg'")
	else
		debug("found external cover: '" .. file .. "'")
	end
	-- standardize the file
	-- only copy desired cover types
	local matched = false
	for _, t in pairs(cover_types) do
		if cover_type == t then
			matched = true
			break
		end
	end
	if matched then
		output.externalcovers[file] = to_jpeg(input_cover, nil, file, new_base_filename)
	else
		output.externalcovers[file] = nil
	end

end

if input.onlinecover.format ~= "" then
	output.onlinecover = to_jpeg(input.onlinecover)
end

