------------------------------------
--	OUTPUT PATH
------------------------------------

-- demlo script

-- set the library directory according to tags
-- apply pathsubs

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

function apply_pathsubs(s)
	for bad, good in pairs(pathsubs) do
		s = s:gsub(bad, good)
	end
	return s
end

local function append(field, before, after)
	if not empty(field) then
		before = before or ''
		after = after or ''
		directory = directory .. apply_pathsubs(before) .. apply_pathsubs(field) .. apply_pathsubs(after)
	end
end

directory = ''

-- hi-res vs lo-res
if library_dir then
	directory = '/home/dylan/audio/library/' .. library_dir
	-- music vs non-music TODO
	directory = directory .. '/music/'
	-- torrent vs non-torrent
	if torrent then
		directory = directory .. 'torrents/' 
		-- artist folder: construct from tags
		append(o.artist)
		directory = directory .. '/'
		-- album folder: copy from input
		local album_folder = input.path:match("/([^/]+)/[^/]+$")
		append(album_folder)
		directory = directory .. '/'
	else
		directory = directory .. 'non-torrents/'
		-- artist folder: construct from tags
		local album_artist = not empty(o.album_artist) and o.album_artist or
			(not empty(o.artist) and o.artist or 'Unknown Artist')
		append(album_artist)
		directory = directory .. '/'
		-- album folder: construct from tags
		if not empty(o.album) then
			append(o.date, '[', '] ')
			append(o.album)
			directory = directory .. '/'
		end
	end
end
