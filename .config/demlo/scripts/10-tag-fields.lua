-----------------------------
-- 10: SANITIZE TAG FIELDS --
-----------------------------

debug([[//===================\\]])
debug([[|| 10-tag-fields.lua ||]])
debug([[\\===================//]])

-- extract any missing tags from filepath
debug("> Extracting tags from file path...")
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
			['re'] = "^([0-9]+)(?:\\.| -)? (.*)",
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
		['track'] = '[0-9]+',
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

for stringname, formats in pairs(format_tables) do
	local string = path_components[stringname]
	for _, format in ipairs(formats) do
		local matches = {string:match(format.re)}
		if #matches > 0 then
			-- assign tags
			for i, tagname in ipairs(format.tagnames) do
				debug("extracted " .. tagname .. ": " .. matches[i])
				if empty(o[tagname]) then
					o[tagname] = matches[i]
				else
					if matches[i] ~= o[tagname] then
						debug("WARNING: extracted " .. tagname .. " differs from existing tag; using existing")
						debug("existing " .. tagname .. ": " .. o[tagname])
					end
				end
			end
			break
		end
	end
end

-- start from a clean set of tags
tags = {}

debug("> Cleaning tag fields...")

-- determine if there's an artist
if not empty(o.artist) then
	tags.artist = o.artist
elseif not empty(o.album_artist) then
	tags.artist = o.album_artist
else
	tags.artist = nil
end

-- determine if there's an album artist
if empty(o.album) then
	-- if there's no album, then there's no an album artist
	tags.album_artist = nil
else
	-- otherwise...
	-- first fish around for the proper tag in the input
	o.album_artist = o.album_artist or o.albumartist or o["album artist"] or o["album-artist"]
	-- then set album_artist to either the found tag or the regular artist
	if not empty(o.album_artist) then
		tags.album_artist = o.album_artist
	else
		tags.album_artist = tags.artist
	end
end

-- always use these tags
tags.album = o.album
tags.composer = o.composer
tags.date = o.date or o.year
tags.comment = o.comment
tags.title = o.title

-- remove leading zeroes from discnumber
tags.disc = not empty(o.album) and not empty(o.disc) and o.disc:match([[0*(\d*)]]) or nil

-- keep leading zeroes in tracknumber
tags.track = not empty(o.album) and not empty(o.track) and o.track:match([[(0*\d*)]]) or nil

-- save the tags
output.tags = tags
