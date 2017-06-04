------------------------------------
--	SANITIZE TAGS
------------------------------------

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
	-- if there's no album, then there's no an album artist
	tags.album_artist = nil
else
	-- otherwise...
	-- first fish around for the proper tag in the input
	o.album_artist = o.album_artist or o.albumartist or o["album artist"]
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
