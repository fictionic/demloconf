---------------------
-- 30: OUTPUT PATH --
---------------------

debug([[//=================\\]])
debug([[|| 30-basename.lua ||]])
debug([[\\=================//]])

-- use local variable to avoid accessing the table over and over
local basename = settings.path.basename

-- make sure it's not nil
if basename == nil then basename = '' end

-- append things to basename
local function append(field, before, after)
	basename = append_to_and_filter(basename, field, before, after, apply_pathsubs)
end

if empty(basename) and not torrent and o.title then
	debug("computing basename from tags...")
	-- filename: construct from tags
	if not empty(o.disc) then
		append(o.disc, nil, '.')
	end
	if not empty(o.track) then
		if tonumber(o.track) then
			-- if track is an int, pad it with an appropriate number of zeroes based on tracktotal
			local padding_amount = 2 -- default = 2
			if not empty(o.tracktotal) then
				padding_amount = #tostring(o.tracktotal)
			end
			local track_padded = string.format('%0' .. padding_amount .. 'd', o.track)
			append(track_padded, nil, '. ')
		else
			-- otherwise add it as-is
			append(o.track, nil, '. ')
		end
		-- TODO: smarter zero padding amounts (if there's an album with 100+ songs)
		-- technically the CD standard requires that no disc can contain more than 99 songs...
		-- but I suppose it could be on a WEB release
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
		debug("using input basename")
	else
		-- use given basename
		debug("using input basename")
		basename = input_basename
	end
end

-- set the global value to our computed value
settings.path.basename = basename

debug("> output basename: '" .. settings.path.basename .. "'")
