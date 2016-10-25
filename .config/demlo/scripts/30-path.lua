------------------------------------
--	OUTPUT PATH
------------------------------------

-- demlo script

-- Set the output path according to tags.
-- Remove problematic characters from result.
-- Set file extention from format.
-- Pad zeros (2 digits) in track number for file browsers without numeric sorting capabilities.

empty = empty or function (s)
	if type(s) ~= 'string' or s == '' then
		return true
	else
		return false
	end
end

local pathsubs = pathsubs or {
	["/"] = ","
}

local function apply_pathsubs(s)
	for bad, good in pairs(pathsubs) do
		s = s:gsub(bad, good)
	end
	return s
end

local function append(field, before, after)
	if not empty(field) then
		before = before or ''
		after = after or ''
		output.path = output.path .. apply_pathsubs(before) .. apply_pathsubs(field) .. apply_pathsubs(after)
	end
end

-- base folder
-----
-- hi-res vs lo-res
if library_dir then
	output.path = '/home/dylan/audio/library/' .. library_dir
	-- music vs non-music TODO
	output.path = output.path .. '/music/'
	-- torrent vs non-torrent
	if torrent then
		output.path = output.path .. 'torrents/' 
		-- artist folder
		append(o.artist)
		output.path = output.path .. '/'
		-- album folder
		local album_folder = input.path:match("/([^/]+)/[^/]+$")
		append(album_folder)
		output.path = output.path .. '/'
		-- filename and extension
		local filename = input.path:match("/([^/]+)\\.[^.]+$")
		local ext = empty(output.format) and input.format.format_name or output.format
		append(filename)
		append('.' .. ext)
	else
		output.path = output.path .. 'non-torrents/'
		-- artist folder
		local album_artist = not empty(o.album_artist) and o.album_artist or
			(not empty(o.artist) and o.artist or 'Unknown Artist')
		append(album_artist)
		output.path = output.path .. '/'
		-- album folder
		if not empty(o.album) then
			append(o.date, '[', '] ')
			append(o.album)
			output.path = output.path .. '/'
		end
		-- filename
		local track_padded = '' -- TODO: smarter zero padding amounts (if there's an album with 100+ songs)
		if not empty (o.track) and tonumber(o.track) then
			track_padded = string.format('%02d', o.track)
		end
		append(o.disc, nil, '.')
		append(track_padded, nil, '. ')
		if o.artist ~= o.album_artist then
			append(o.artist, nil, ' - ')
		end
		append(o.title)
		-- extension
		local ext = empty(output.format) and input.format.format_name or output.format
		append('.' .. ext)
	end
else
	output.path = ''
end
