---------------------
-- 30: OUTPUT PATH --
---------------------

debug([[//==================\\]])
debug([[|| 31-directory.lua ||]])
debug([[\\==================//]])

-- use local variable to avoid accessing the table over and over
local directory = settings.path.directory

-- make sure it's not nil
if directory == nil then directory = '' end

-- append things to directory
local function append(field, before, after)
	directory = append_to_and_filter(directory, field, before, after, apply_pathsubs)
end

if empty(directory) then
	-- hi-res vs lo-res
	if settings.library.sublibrary then
		debug("assembling directory from tags...")
		directory = settings.library.location .. settings.library.sublibrary
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
			local album_artist = not empty(o.album_artist) and o.album_artist
				or not empty(o.artist) and o.artist
				or 'Unknown Artist'
			append(album_artist)
			directory = directory .. '/'
			-- album folder: construct from tags
			if not empty(o.album) then
				append(o.date, '[', '] ')
				debug("appending album")
				append(o.album)
				directory = directory .. '/'
			end
		end
	else
		-- extract default directory from input path
		directory = input_directory
		debug("extracted directory from input path")
	end
else
	debug("using given directory: '" .. directory .. "'")
end

-- ensure there is no ending slash
directory = directory:gsub("/$","")

-- save it to global settings
settings.path.directory = directory

debug("> output directory: '" .. directory .. "'")
