------------------------------------
--	SANITIZE TAGS
------------------------------------
-- demlo script
-- Sanitize tags.

-- Unknown tag fields are removed.
--
-- Tags 'album_artist', 'artist', and 'composer' are easily mixed up. You may
-- need to switch their values from command-line on a per-album basis.
--
-- References:
-- http://musicbrainz.org/doc/MusicBrainz_Picard/Tags/Mapping
-- http://musicbrainz.org/doc/Classical_Music_FAQ


-- Start from a clean set of tags.
tags = {}

function empty(s)
	return (type(s) ~= 'string' or s == '')
end

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
	tags.album_artist = nil
else
	if not empty(o.album_artist) then
		tags.album_artist = o.album_artist
	else
		tags.album_artist = tags.artist
	end
end

-- always use these tags
tags.album = o.album
tags.composer = o.composer
tags.date = o.date
tags.comment = o.comment
tags.title = o.title

-- Disc and track numbers only matter if the file is part of an album. 
--
-- For disknumber, consider the first number only, and remove leading zeroes 
tags.disc = not empty(o.album) and not empty(o.disc) and o.disc:match([[0*(\d*)]]) or nil
--
-- For tracknumber, consider the first number only, and keep leading zeroes
tags.track = not empty(o.album) and not empty(o.track) and o.track:match([[(0*\d*)]]) or nil
