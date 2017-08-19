---------------------
-- 30: OUTPUT PATH --
---------------------

debug([[//=================\\]])
debug([[|| 30-basename.lua ||]])
debug([[\\=================//]])

apply_pathsubs = apply_pathsubs or function (s)
	for bad, good in pairs(pathsubs) do
		s = s:gsub(bad, good)
	end
	return s
end

local function append(field, before, after)
	if not empty(field) then
		before = before or ''
		after = after or ''
		basename = basename .. apply_pathsubs(before) .. apply_pathsubs(field) .. apply_pathsubs(after)
	end
end

basename = name or ''

if empty(basename) and not torrent and o.title then
	debug("computing basename from tags...")
	-- filename: construct from tags
	if not empty(o.disc) then
		append(o.disc, nil, '.')
	end
	local track_padded
	if not empty(o.track) and tonumber(o.track) then
		track_padded = string.format('%02d', o.track)
		append(track_padded, nil, '. ')
		-- TODO: smarter zero padding amounts (if there's an album with 100+ songs)
	end
	if o.album_artist and (various_artists_format_always_allowed or o.album_artist:match("[Vv]arious( [Aa]rtists)?")) then
		-- check if filename should indicate artist
		if o.artist ~= o.album_artist then
			append(o.artist, nil, ' - ')
		end
	end
	append(o.title)
else
	if name then
		-- keep basename as-is
		debug("using given basename")
	else
		-- use given basename
		debug("using old basename")
		basename = input.path:match("^.+?/([^/]+)\\.[^.]+$")
	end
end

debug("basename: '" .. basename .. "'")
