---------------------
-- 30: OUTPUT PATH --
---------------------

-- debug([[//=================\\]])
-- debug([[|| 31-basename.lua ||]])
-- debug([[\\=================//]])

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

basename = ''

-- torrent vs non-torrent
if not torrent then
	-- filename: construct from tags
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
end
-- (otherwise let it be copied from input by 50-path)
