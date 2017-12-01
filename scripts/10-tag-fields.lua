-----------------------------
-- 10: SANITIZE TAG FIELDS --
-----------------------------

debug([[//===================\\]])
debug([[|| 10-tag-fields.lua ||]])
debug([[\\===================//]])

-- extract any missing tags from filepath
if settings.tag.extract_tags then
	debug(">> Extracting tags from file path...")
	local path_components = {}
	path_components.dirname, path_components.basename = input.path:match("(^/(?:[^/]+/)*[^/]+)/([^/]+)\\.[^.]+$")

	-- builtin format strings
	local format_tables = {
		['dirname'] = {
			{
				-- "artist - album (date)/Disc N"
				['re'] = ".*/([^/]*) - ([^/]*) \\(([0-9]{4}(?:-[0-9]{2}-[0-9]{2})?)\\)/Disc ([0-9]+)",
				['tagnames'] = {'artist', 'album', 'date', 'disc'}
			},
			{
				-- "artist - album (date)"
				['re'] = ".*/([^/]+) - ([^/]+) \\(([0-9]{4}(?:-[0-9]{2}-[0-9]{2})?)\\)",
				['tagnames'] = {'artist', 'album', 'date'}
			},
			{
				-- "artist - album"
				['re'] = ".*/([^/]*) - ([^/]*)",
				['tagnames'] = {'artist', 'album'}
			},
			{
				-- "[date] album"
				['re'] = [=[.*/\[(\d{4}(?:-\d\d(?:-\d\d)?)?)\] ([^/]*)]=],
				['tagnames'] = {'date', 'album'}
			},
			{
				-- "album"
				['re'] = ".*/([^/]*)",
				['tagnames'] = {'album'}
			}
		},
		['basename'] = {
			{
				-- "disc.track. title"
				['re'] = "^([0-9]+)\\.([0-9]+)(?:\\.| -)? (.*)",
				['tagnames'] = {'disc', 'track', 'title'}
			},
			{
				-- "track. title"
				['re'] = "^([A-D]?[0-9]+)(?:\\.| -)? (.*)",
				['tagnames'] = {'track', 'title'}
			},
		}
	}

	-- if the user provided a format string
	if not empty(basenameformat) then
		local basename_format_table = {
			['re'] = '',
			['tagnames'] = {}
		}
		local tag_mapping = {
			['date'] = [[\d{4}(?:-\d\d(?:-\d\d)?)?]],
			['disc'] = '[0-9]+',
			['track'] = '[A-D]?[0-9]+',
			-- all the rest are '.*' by default
		}
		-- construct format table
		for tagname in basenameformat:gmatch([[%\(([^)]+)\)]]) do
			local re, nongreedy
			if tagname:sub(-1) == '?' then
				tagname = tagname:sub(1,-2)
				re = tag_mapping[tagname] or '.+?'
				basenameformat = basenameformat:gsub([[%\(]] .. tagname .. [[\?\)]], "(" .. re .. ")")
			else
				re = tag_mapping[tagname] or '.+'
				basenameformat = basenameformat:gsub([[%\(]] .. tagname .. [[\)]], "(" .. re .. ")")
			end
			table.insert(basename_format_table['tagnames'], tagname)
		end
		basename_format_table['re'] = basenameformat
		debug(basenameformat)
		if path_components.basename:match(basenameformat) then
			debug("user format string matched; using")
			format_tables['basename'] = {basename_format_table}
		else
			debug("user format string does not match; falling back on builtins")
		end
	end

	-- force_extract stuff
	local fe = settings.tag.force_extract
	local fe_tags = {}
	if not empty(fe) and fe ~= 'all' then
		for tagname in fe:gmatch([[[a-z]+]]) do
			debug(tagname)
			fe_tags[tagname] = true
		end
	end

	for stringname, formats in pairs(format_tables) do
		local string = path_components[stringname]
		for _, format in ipairs(formats) do
			local matches = {string:match(format.re)}
			if #matches > 0 then
				-- assign tags
				for i, tagname in ipairs(format.tagnames) do
					debug("> extracted " .. tagname .. ": " .. matches[i])
					if empty(o[tagname]) then
						o[tagname] = matches[i]
					else
						if matches[i] ~= o[tagname] then
							debug("existing " .. tagname .. ": " .. o[tagname])
							if fe == 'all' or fe_tags[tagname] == true then
								debug("INFO: extracted " .. tagname .. " differs from existing tag; using extracted")
								o[tagname] = matches[i]
							else
								debug("WARNING: extracted " .. tagname .. " differs from existing tag; using existing")
							end
						end
					end
				end
				break
			end
		end
	end
end

-- start from a clean set of tags
tags = {}

debug(">> Cleaning tag fields...")

-- find artist
local artist = not empty(o.artist) and o.artist or nil
if not empty(artist) then
	debug("found artist: " .. artist)
end

-- find album_artist
local album_artist = o.album_artist or o.albumartist or o["album artist"] or o["album-artist"] or nil
if not empty(album_artist) then
	debug("found album_artist: " .. album_artist)
end

-- set artist
tags.artist = not empty(artist) and artist or not empty(album_artist) and album_artist or nil
-- set album_artist
if empty(o.album) then
	-- if there's no album, then there's no an album artist
	tags.album_artist = nil
	debug("no album; leaving albumartist empty")
else
	-- if not found, set it to the regular artist
	if empty(album_artist) then
		tags.album_artist = tags.artist
		debug("using artist as album_artist")
	else
		tags.album_artist = album_artist
	end
end

-- always use these tags
tags.album = o.album
tags.composer = o.composer
tags.date = o.date or o.year or o['release date']
if not empty(date) then
	debug("found date: " .. tags.date)
end
tags.comment = o.comment
tags.title = o.title
debug("found title: " .. tags.title)

if not empty(tags.album) then
	-- remove leading zeroes from tracknumber and discnumber
	if not empty(o.track) then
		tags.track = o.track:match([[0*(\d*)]]) or o.track
	else
		tags.track = nil
	end
	if not empty(o.disc) then
		tags.disc = o.disc:match([[0*(\d*)]]) or o.disc
	else
		tags.disc = nil
	end

	-- get track/disc totals
	local track_total_possibilities = {'tracktotal', 'totaltracks', 'track_total', 'total_tracks', 'track total', 'total tracks'}
	for _, possibility in ipairs(track_total_possibilities) do
		if not empty(o[possibility]) then
			tags.tracktotal = o[possibility]
			break
		end
	end
	local disc_total_possibilities = {'disctotal', 'totaldiscs', 'disc_total', 'total_discs', 'disc total', 'total discs', 'disktotal', 'totaldisks', 'disk_total', 'total_disks', 'disk total', 'total disks'}
	for _, possibility in ipairs(disc_total_possibilities) do
		if not empty(o[possibility]) then
			tags.disctotal = o[possibility]
			break
		end
	end
end
-- save the tags
output.tags = tags
