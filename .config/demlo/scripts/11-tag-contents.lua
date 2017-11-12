-------------------------------
-- 11: SANITIZE TAG CONTENTS --
-------------------------------

debug([[//=====================\\]])
debug([[|| 11-tag-contents.lua ||]])
debug([[\\=====================//]])

-- Overview:
-- The tags 'title', 'album', 'album_artist', and 'artist' need to be capitalized properly.
-- Rather than treating each tag as a single entity, it is necessary to treat them as series
-- of "components", each component needing to be capitalized on its own. For instance, a title
-- may have a parenthetical subtitle: 'Evolution (The Grand Design)'--in this case, the subtitle
-- begins with a word that is normally uncapitalized, but it should be capitalized in this case
-- because it begins a new title.
-- A component contains two things: a string (a substring of a tag value), and a boolean,
-- indicating whether or not the component should be capitalized according to the predefined rules
-- or if it should be left alone.
--
-- Tag values are broken into components by being matched against 'feature templates'. A feature
-- template is a regular expression that is meant to match on certain portions of certain tags,
-- along with a function that assembles the substrings into a sanitized string. That is, they 
-- have a meaning associated with them, and this meaning determines which portions of the matching
-- string should be put into components in which way.
--
-- For example, the template `parenthetical_alternate_mix_indication` matches on titles like
-- "Easy (Remix ft. Busdriver)", and extracts the name of the remixer along with the fact that
-- the song is a remix--specifically, it adds components "remix feat. " and "Busdriver" to
-- the title tag, the first to remain unaltered, and the second to be capitalized to titlecase,
-- as an artist name should be.
--
-- At the end of the process, the components are assembled back into newly-santized tags.

-- add a component to a given tag's table
local function add_component(tag, component, capitalize)
	if component:len() > 0 then
		dest_table = components[tag]
		if not capitalize and #dest_table > 0 and not dest_table[#dest_table].capitalize then
			debug("appending to prev component: '" .. component .. "' (not capitalizing)")
			prev_component = dest_table[#dest_table].component
			dest_table[#dest_table].component = prev_component .. component
		else
			if capitalize then note = "capitalizing" else note = "not capitalizing" end
			debug("adding new component: '" .. component .. "' (" .. note .. ")")
			table.insert(components[tag], {['component'] = component, ['capitalize'] = capitalize})
		end
	end
end

--------------------------------------
-- for converting decimal numbers to roman numerals
local function decimal_to_roman(s)
	numbers = {1, 5, 10, 50, 100, 500, 1000}
	chars = {'I', 'V', 'X', 'L', 'C', 'D', 'M'}
	if s == '' then return '' end
	d = tonumber(s)
	if not d or d ~= d then return '' end
	d = math.floor(d)
	local ret = ""
	for i = #numbers, 1, -1 do
		local num = numbers[i]
		while d - num >= 0 and d > 0 do
			ret = ret .. chars[i]
			d = d - num
		end
		for j = 1, i - 1 do
			local n2 = numbers[j]
			if d - (num - n2) >= 0 and d < num and d > 0 and num - n2 ~= n2 then
				ret = ret .. chars[j] .. chars[i]
				d = d - (num - n2)
				break
			end
		end
	end
	return ret
end
-- for converting english number words into roman numerals
local function english_to_roman(s)
	mapping = {
		['one'] = 'I',
		['two'] = 'II',
		['three'] = 'III',
		['four'] = 'IV',
		['five'] = 'V',
		['six'] = 'VI',
		['seven'] = 'VII',
		['eight'] = 'VIII',
		['nine'] = 'IX',
		['ten'] = 'X'
	}
	return mapping[s]
end

-----------------------
-- FEATURE TEMPLATES --
-----------------------

local featured_performer_from_artist = nil
local disc_number_from_album = nil

-- non-parenthetical featured performer
-- e.g. title: "Forever, Feat. Eminem"
-- e.g. artist: "Drake Ft Eminem"
local non_parenthetical_featured_performer = {
	['re'] = [[((?:,| -)? (?i:f(?:ea)?t(?:\.|uring)?) (.*))$]],
	['func'] = function (tag, matches, rest)
		debug("found non-parenthetical featured performer")
		if tag == 'artist' then
			featured_performer_from_artist = matches[2]
		else -- tag == 'title'
			add_component(tag, '[feat. ', false)
			add_component(tag, matches[2], true)
			add_component(tag, ']', false)
		end
		return rest
	end
}

-- multiple titles in the same tag, not in parentheses
-- e.g. "Lovers in Japan / Reign of Love",
-- e.g. "The Princess and the Queen, or, The Blacks and the Greens"
-- but NOT, e.g., "Action/Reaction"
local polytitle = {
	['re'] = "( / |, [oO]r, )",
	['func'] = function (tag, matches, rest)
		debug("found polytitle indication")
		add_component(tag, matches[1]:lower(), false)
		return rest
	end
}

local part_introducer_re = "(?: ?[-,:;–]? ?)"
local part_type_re = [=[(?i:pt\.?|part|vol\.?|volume)]=]
-- local part_type_re = [=[\b[^ ]+\b]=]
local part_type_index_sep_re = "[- _]"
local part_index_re = "(?:[0-9IVXLCDM]+|(?i:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty))"
local part_subtitle_introducer_re = "( ??[-,.:])?"

-- titles indicating multiple parts of a work
-- e.g. "TEAR, Pt. I"
-- e.g. "Metropolis, Pt. I: The Miracle and the Sleeper"
-- e.g. "Unholy Wars, Pt. I: Imperial Crown; Pt. II: Forgiven Return"
-- e.g. "Through the Looking Glass, Pts. I-III"
-- e.g. "Phase I: Singularity - The Theory of Everything, Pt. I"
local multipart = {
	['re'] = '(' .. part_introducer_re .. '(' .. part_type_re .. ')' .. part_type_index_sep_re .. '(' .. part_index_re .. ')' .. part_subtitle_introducer_re .. ')',
	['func'] = function (tag, matches, rest)
		debug("found multi-part indication")
	end
}

-- types of multipart titles
--		title, type index
--		title, type index1-indexN
--		title, type index: subtitle
--		title, type1 index1: subtitle1; type1 index2; subtitle2; ...
--		type1 index1: subtitle1 - type2 index21: subtitle21

-- one part indicated at a time
-- e.g. "TEAR, Pt. 1"
-- e.g. "Unholy Wars, Pt. I: Imperial Crown; Pt. II: Forgiven Return"
local uni_multipart = {
	['re'] = '(' .. part_introducer_re .. '(' .. part_type_re .. ')' .. part_type_index_sep_re .. '(' .. part_index_re .. ')' .. part_subtitle_introducer_re .. ')',
	['func'] = function (tag, matches, rest)
		debug("found multi-part indication")
		if part_introducer == nil then
			part_introducer = ','
		end
		partindex = matches[3]
		if partindex:match('[0-9]+') then
			oldpartindex = partindex
			partindex = decimal_to_roman(oldpartindex)
			debug('partindex: ' .. oldpartindex .. ' -> ' .. partindex)
		elseif not partindex:match('[IVXLCDM]+') then
			oldpartindex = partindex
			partindex = english_to_roman(oldpartindex:lower())
			debug('partindex: ' .. oldpartindex .. ' -> ' .. partindex)
		else
			debug('partindex: ' .. partindex)
		end
		if matches[2]:match([[(?i:volume)]]) then
			to_add = part_introducer .. ' Volume ' .. partindex
		elseif matches[2]:match([[(?i:vol\.?)]]) then
			to_add = part_introducer .. ' Vol. ' .. partindex
		else
			to_add = part_introducer .. " Pt. " .. partindex
		end
		if rest:len() > 0 then to_add = to_add .. ':' end -- if there's a subtitle we should delimit it with a colon
		add_component(tag, to_add, false)
		part_introducer = ';' -- if multiple parts are indicated in the same tag, we should separate them with a semicolon, not a comma
		-- TODO: take out surrounding parentheses from subtitle (next component) if present?
		return rest
	end
}

-- titles indicating multiple parts of a work, multiple parts indicated at a time
-- e.g. "Through the Looking Glass, Pts. I-III"
local multi_multipart = {
	['re'] = [[((?: - |, )\(?(?i:p(?:ar)?ts?\.?) (]] .. part_index_re .. [[)(?:-|(?:, | & |\+| \+ | and )(]] .. part_index_re .. [[))+(?:, | & |\+| \+ | and )(]] .. part_index_re .. [[)\)?)]],
	['func'] = function (tag, matches, rest)
		debug("found multi-multi-part indication")
		part_indeces = {matches[2], matches[#matches]}
		for i, _ in ipairs(part_indeces) do
			if i == 1 then i_str = 'start ' else i_str = 'end ' end
			if part_indeces[i]:match('[0-9]+') then
				oldpartindex = part_indeces[i]
				part_indeces[i] = decimal_to_roman(oldpartindex)
				debug(i_str .. 'partindex: ' .. oldpartindex .. ' -> ' .. part_indeces[i])
			elseif not part_indeces[i]:match('[IVXLCDM]+') then
				oldpartindex = part_indeces[i]
				part_indeces[i] = english_to_roman(oldpartindex:lower())
				debug(i_str .. 'start partindex: ' .. oldpartindex .. ' -> ' .. part_indeces[i])
			else
				debug(i_str .. 'start partindex: ' .. part_indeces[i])
			end
		end
		to_add = ', Pts. ' .. part_indeces[1] .. '-' .. part_indeces[2]
		add_component(tag, to_add, false)
		return rest
	end
}

-- clause delimiters
-- e.g. "Retreat! Retreat!"
-- > BUT NOT e.g. "You Eat Houmous, of Course You Listen to Genesis"
-- ('of' should be uncapitalized)
local clause = {
	['re'] = [=[((?:\.|[?!]+|:|;| -|—) )]=],
	['func'] = function (tag, matches, rest)
		debug("found clause delimiter")
		add_component(tag, matches[1], false)
		return rest
	end
}

-- indication of disc number
-- e.g. "Iconoclast Disc 1"
local disc_indication = {
	['re'] = "( (?:[dD]is[ck]|CD) ?([[:digit:]]+)(?:/[[:digit:]]+)?)",
	['func'] = function (tag, matches, rest)
		debug("found discnumber indication")
		disc_number_from_album = matches[2]
		return rest
	end
}

-- quotations
-- e.g. "Theme of CRISIS CORE 'With Pride'"
local quotation = {
	['re'] = [=[((\W|^)('|")(\w))]=],
	['func'] = function (tag, matches, rest)
		valid = true
		-- see if it's a single quote or a double quote
		if matches[3] == [[']] then
			q_type = 1
			end_index = rest:find([[\w'(\W|$)]]) + 1
			if end_index == 0 then
				valid = false
			else
				quote = matches[4] .. rest:sub(1, end_index-1)
			end
		else
			q_type = 2
			end_index = rest:find([[\w"(\W|$)]]) + 1
			if end_index == 0 then
				valid = false
			else
				quote = matches[4] .. rest:sub(1, end_index-1)
			end
		end
		if valid then
			debug("found quotation")
			-- add what comes before the quote
			if matches[2]:len() > 0 then
				add_component(tag, matches[2], false)
			end
			-- add the quote
			if q_type == 1 then
				add_component(tag, "'" .. quote .. "'", true)
			else
				add_component(tag, '"' .. quote .. '"', true)
			end
			return rest:sub(end_index+1)
		else
			-- undo capturing anything; it's not actually a quotation
			return matches[1] .. rest
		end
	end
}

-----
-- various types of parentheticals
-----

local parenthetical_instrumental_indication = {
	['re'] = "^(?i:instrumental(?: mix)?$)",
	['func'] = function (tag, matches)
		debug("found instrumental indication")
		add_component(tag, '(instrumental)', false)
	end
}

local parenthetical_cover_indication = {
	['re'] = "^(.+ )?(?i:cover)$",
	['func'] = function (tag, matches)
		debug("found cover indication")
		add_component(tag, '[' .. matches[1] .. 'cover]', false)
	end
}

local parenthetical_featured_performer = {
	['re'] = [[^(?i:f(?:(?:ea)?t\.?)|eaturing) (.*)$]],
	['func'] = function (tag, matches) 
		debug("found parenthetical featured performer")
		if tag == 'artist' then
			featured_performer_from_artist = matches[1]
		else -- tag == 'title'
			add_component(tag, '[feat. ', false)
			add_component(tag, matches[1] .. ']', true)
		end
	end
}

-- also tests for alternate mixes with featured performers
-- e.g. "Easy (remix feat. Busdriver)"
local parenthetical_alternate_mix_indication = {
	['re'] = [[^(?:(.*) )?((?i:(?:(?:re-?)?mix)|edit))(?i:(?:,| -)? f(?:ea)?t(?:\.|uring)? (.*))?$]],
	['func'] = function (tag, matches)
		debug("found alternate mix indication")
		to_add = '('
		mix_name = matches[1]
		if #mix_name > 0 then
			if mix_name:match('(?i:alt(\\.|ernate)?)') then
				mix_name = mix_name:lower()
			end
			to_add = to_add .. mix_name .. ' '
		end
		mix_type = matches[2]
		if mix_type:match('(?i:re-mix)') then
			mix_type = 'remix'
		end
		mix_type = mix_type:lower()
		to_add = to_add .. mix_type
		if #matches[3]  > 0 then
			to_add = to_add .. ' ' .. tag_settings.featured_performer_format .. ' ' .. matches[3]
		end
		to_add = to_add .. ')'
		add_component(tag, to_add, false)
	end
}

local parenthetical_alternate_recording_indication = {
	['re'] = "^(?i:((?:demo|(?:early|earlier|demo) version)|(?:(?:acoustic|studio)?)(?: version)?))$",
	['func'] = function (tag, matches)
		debug("found alternate recording indication")
		if matches[1]:match("^[Dd]emo [Vv]ersion$") then
			matches[1] = "demo"
		end
		add_component(tag, '(' .. matches[1]:lower() .. ')', false)
	end
}

local parenthetical_live_recording_indication = {
	['re'] = "(?i:live(?: (from|at) (the )?(.*))?)",
	['func'] = function (tag, matches)
		debug("found live recording indication")
		add_component(tag, '(live ' .. matches[1]:lower() .. ' ' .. matches[2]:lower(), false)
		add_component(tag, matches[3], true)
		add_component(tag, ')', false)
	end
}

local parenthetical_alternate_version_indication = {
	['re'] = "^(?i:(.*) version)$",
	['func'] = function (tag, matches)
		debug("found alternate version indication")
		add_component(tag, '(', false)
		if matches[1]:match('^(?i:alternate|earl(y|ier)|strings|ukulele|saxophones)$') then
			add_component(tag, matches[1]:lower(), false)
		else
			add_component(tag, matches[1], true)
		end
		add_component(tag, ' version)', false)
	end
}

local parenthetical_reprise_indication = {
	['re'] = "^[Rr]eprise$",
	['func'] = function (tag, matches)
		debug("found parenthetical reprise indication")
		add_component(tag, "(reprise)", false)
	end
}

local parenthetical_disc_indication = {
	['re'] = "^(?:[dD]isc|CD) ?([[:digit:]]+)(?:/[[:digit:]]+)?",
	['func'] = function (tag, matches)
		debug("found parenthetical discnumber indication")
		-- (don't add any component to tag)
		disc_number_from_album = matches[1]
	end
}

local parenthetical_single_indication = {
	['re'] = "^[Ss]ingle$",
	['func'] = function (tag, matches)
		debug("found parenthetical single indication")
		add_component(tag, '[single]', false)
	end
}

local parenthetical_alternate_release_indication = {
	['re'] = "^(.* )[Rr]elease$",
	['func'] = function (tag, matches)
		debug("found parenthetical alternate release indication")
		add_component(tag, matches[1], true)
		add_component(tag, 'release', false)
	end
}


local parenthetical_alternate_edition_indication = {
	['re'] = "(?i:(.*) edition)",
	['func'] = function (tag, matches)
		debug("found parenthetical alternate edition indication")
		if matches[1]:match('(?i:(japanese|deluxe|special|limited))') then
			if matches[1]:match('(?i:japanese)') then
				add_component(tag, '(Japanese edition)', false)
			else
				add_component(tag, '(' .. matches[1]:lower() .. ' edition)', false)
			end
		else
			add_component(tag, '(' .. matches[1], true)
			add_component(tag,  ' edition)', false)
		end
	end
}

-- if none of the above match, it's probably a subtitle
local parenthetical_subtitle = {
	['re'] = ".*",
	['func'] = function (tag, matches, square)
		debug("found parenthetical subtitle")
		if square then
			add_component(tag, '[' .. matches[1] .. ']', false) -- leave capitalization alone inside square-bracketed subtitles, as they're probably not titles
		else
			add_component(tag, '(' , false)
			return true
		end
	end
}

-- which types of parentheticals can appear in each tag
local parenthetical_possibilities = {
	['artist'] = {
		parenthetical_featured_performer,
		parenthetical_subtitle
	},
	['album_artist'] = {
		parenthetical_subtitle
	},
	['album'] = {
		parenthetical_featured_performer,
		parenthetical_cover_indication,
		parenthetical_disc_indication,
		parenthetical_single_indication,
		parenthetical_alternate_edition_indication,
		parenthetical_subtitle
	},
	['title'] = {
		parenthetical_featured_performer,
		parenthetical_alternate_mix_indication,
		parenthetical_alternate_recording_indication,
		parenthetical_live_recording_indication,
		parenthetical_alternate_version_indication,
		parenthetical_cover_indication,
		parenthetical_instrumental_indication,
		parenthetical_reprise_indication,
		parenthetical_subtitle
	}
}

-- the parenthetical meta-feature
-- (determines which sub-feature is a match)
local parenthetical = {
	['re'] = [=[ (\(|\[)]=],
	['func'] = function (tag, matches, rest)
		if matches[1] == '(' then
			end_index = rest:find([[\)]])
			parenthetical = rest:sub(1, end_index-1)
			square = false
		else
			end_index = rest:find(']')
			parenthetical = rest:sub(1, end_index-1)
			square = true
		end
		-- analyze what's inside the parentheses
		for _, possibility in ipairs(parenthetical_possibilities[tag]) do
			-- assemble the matches into a table so they can be
			-- handled properly by the function we'll call
			inner_matches = {parenthetical:match(possibility.re)}
			if inner_matches[1] then
				scan_parenthetical = possibility.func(tag, inner_matches, square)
				break
			end
		end
		-- if we should continue scanning after the end of the parenthetical
		-- (for parenthetical subtitle we shouldn't, since there might be
		-- other components inside the parenthetical, like quotes)
		if scan_parenthetical then
			return rest
		else
			return rest:sub(end_index+1)
		end
	end
}

-- closing parentheses and square brackets
--
-- (quotes do not have this for two reasons:
-- 1. there are (generally) not separate
-- characters for opening and closing quotes.
-- 2. things within quotes are probably not
-- going to contain other sorts of components,
-- whereas parentheticals might.)
local closing_paren = {
	['re'] = [=[(\)|\])]=],
	['func'] = function (tag, matches, rest)
		debug('found closing delimiter')
		add_component(tag, matches[1], false)
		return rest
	end
}

-- COMPONENTS THAT MAY APPEAR IN EACH TAG
local possible_components = {
	['artist'] = {
		non_parenthetical_featured_performer,
		parenthetical,
		closing_paren,
		clause,
		quotation
	},
	['album_artist'] = {
		parenthetical,
		clause,
		closing_paren,
		quotation
	},
	['album'] = {
		polytitle,
		uni_multipart,
		multi_multipart,
		disc_indication,
		parenthetical,
		closing_paren,
		clause,
		quotation
	},
	['title'] = {
		polytitle,
		uni_multipart,
		multi_multipart,
		non_parenthetical_featured_performer,
		parenthetical,
		closing_paren,
		clause,
		quotation
	}
}

-- the main function
local function analyze_tag(tag)
	cap_next = true
	remaining = tags[tag]
	while true do
		local closest_component = nil
		local closest_component_start_index = nil
		local closest_component_end_index = nil
		local matches = {}
		-- find the nearest component separator
		for _, cur_component in ipairs(possible_components[tag]) do
			matches = {remaining:match(cur_component.re)}
			if matches[1] then
				-- debug(cur_component.re)
				-- get bounds of match to consume
				start_index, end_index = remaining:find(matches[1], 1, true)
				-- see if this match is closer than any previous ones
				if closest_component_start_index == nil or start_index < closest_component_start_index then
					closest_component_start_index = start_index
					closest_component_end_index = end_index
					closest_component_matches = matches
					closest_component = cur_component
				end
			end
		end
		-- if none matched
		if closest_component_start_index == nil then
			add_component(tag, remaining, cap_next)
			break
		else
			before = remaining:sub(1, closest_component_start_index-1)
			match = remaining:sub(closest_component_start_index, closest_component_end_index)
			-- add portion of string before component separator
			-- (if it doesn't contain word characters, don't bother capitalizing it)
			if not before:match([[([\pL\pN][\pL\pN'´’]*[\pL\pN]|[\pL\pN])]]) then
				cap_next = false
			end
			add_component(tag, before, cap_next)
			-- take appropriate action with remainder of string
			remaining = closest_component.func(tag, closest_component_matches, remaining:sub(closest_component_end_index+1))
			-- capitalize next component (so first and last words are capitalized)
			cap_next = true
		end
	end
end

-- do the analysis --
---------------------

debug([[   --------------   ]])
debug([[>> analyzing tags <<]])
debug([[   --------------   ]])

tags = tags or {} -- in case 10-tag-fields wasn't run

components = {}
for tag, _ in pairs(tags) do
	if possible_components[tag] then
		debug('> analyzing ' .. tag)
		components[tag] = {}
		analyze_tag(tag)
	end
end

-- append featured performer from artist to title
if featured_performer_from_artist then
	debug("appending featured performer indication to title")
	add_component('title', ' (feat. ' .. featured_performer_from_artist .. ')', false)
end

-- set discnumber to any found in album
if disc_number_from_album then
	debug("setting discnumber to that found in album tag")
	tags.disc = disc_number_from_album
end


------------------------------------
--	SYNTHESIZE TAGS
------------------------------------

debug([[   ---------------   ]])
debug([[>> assembling tags <<]])
debug([[   ---------------   ]])

-- analyze & fix composer
if not empty(tags.composer) then
	-- fix redundant composer
	if tags.composer == tags.artist then
		tags.composer = nil
	else
		-- if composer is made up of semicolon-separated names,
		-- change the semicolons to commas
		if string.match(tags.composer, "^(?:[^;]+; )+[^;]+$") then
			tags.composer = tags.composer:gsub(";", ",")
		end
	end
end

--	standardize case
------------------------------------

-- casing options -- no enums :(
local LEAVE_ALONE = 0
local LOWERCASE = 1
local CAPITALIZE = 2
local UPPERCASE = 3

-- constants are written as provided, except if they begin a component, in which
-- case the first letter is uppercase, or, if sentencecase is not set, if they
-- end a component.
--
-- when sentencecase is set to true, only the first letter of every component will
-- be capitalized, the other words that are not subject to the rules will be
-- lowercase.
--
-- this function was adapted from a script that was
-- inspired by http://www.pement.org/awk/titlecase.awk.txt
local function setcase(input)
	-- Process words from 'input' one by one and append them to 'output'.
	local output = {}

	seps_words = {}
	-- separate into a sequence of nonword-word pairs
	for sep, word in input:gmatch([[([^\pL\pN]*)([\pL\pN][\pL\pN'´’]*[\pL\pN]|[\pL\pN])]]) do
		table.insert(seps_words, {['sep'] = sep, ['word'] = word})
	end

	for i, sep_word in ipairs(seps_words) do
		sep = sep_word.sep
		word = sep_word.word

		-- add sep (for now, just a space or an empty string)
		table.insert(output, sep)
		
		-- save some function calls
		local lower = word:lower()
		local upper = word:upper()
		local capitalized = upper:sub(1, 1) .. lower:sub(2)

		-- Control the casing that should be applied
		local casing = CAPITALIZE

		-- Constants (only check if not the first or last word)
		if i > 1 and i < #seps_words then
			-- lowercase constants
			for _, c in ipairs(tag_settings.const_lower) do
				if lower == c then
					if word ~= c then
						debug("matched lowercase constant '" .. word .. "' --> '" .. lower .. "'")
					else
						debug("matched lowercase constant '" .. word .. "'")
					end
					casing = LOWERCASE
				end
			end
			-- prepositions
			for c, list in pairs(tag_settings.const_preposition) do
				if lower == c then
					matched_exception = false
					for _, preceding_word in ipairs(list) do
						if prev_word == preceding_word then
							debug("matched preposition constant within exception phrase '" .. word .. "'")
							casing = LEAVE_ALONE
							break
						end
					end
					if not matched_exception then
						if word ~= lower then
							debug("matched preposition constant '" .. word .. "' --> '" .. lower .. "'")
						else
							debug("matched preposition constant '" .. word .. "'")
						end
						casing = LOWERCASE
					end
					break
				end
			end
			-- uppercase constants
			for _, c in ipairs(tag_settings.const_upper) do
				if upper == c then
					if word ~= upper then
						debug("matched uppercase constant '" .. word "' --> '" .. upper .. "'")
					else
						debug("matched uppercase constant '" .. word .. "'")
					end
					casing = UPPERCASE
				end
			end
		end

		-- Single-word artist names (in album titles, generally)
		if not matched and word == o.artist then
			debug("matched single-word artist name '" .. word .. "'")
			casing = LEAVE_ALONE
		end

		-- Acronyms (series of capital letters each followed by a period)
		if not matched and word:match([=[(?:[A-Z]\.){2,}]=]) then
			debug("matched acronym: '" .. word .. "'")
			casing = LEAVE_ALONE
		end

		if tag_settings.keep_all_caps then
			-- Words that are at least 2 characters long and already all-caps
			if not matched and word:len() > 2 and word == word:upper() then
				debug("matched all-caps word: '" .. word .. "'")
				casing = LEAVE_ALONE
			end
		end

		if tag_settings.keep_mixed_case then
			-- Words that are longer than 2 characters and already mixed-case
			if not matched and word:match('(?:.+?[[:upper:]][[:lower:]]|[[:lower:]]+?[[:upper:]])') then
				debug("matched mixed-case word: '" .. word .. "'")
				casing = LEAVE_ALONE
			end
		end

		if tag_settings.keep_all_lower then
			-- Words that are longer than 2 characters and already all lowercase
			if not matched and word:len() > 2 and word == word:lower() then
				debug("matched all-lowercase word: '" .. word .. "'")
				casing = LEAVE_ALONE
			end
		end

		-- capitalize the first word of the component
		if i == 1 then
			if casing == LEAVE_ALONE then
				table.insert(output, word)
			elseif casing == UPPERCASE then
				table.insert(output, upper)
			else
				table.insert(output, capitalized)
			end
		else
			-- determine how we should capitalize the rest of the words
			if sentencecase then
				if casing ~= LEAVE_ALONE then
					if casing == LOWERCASE or casing == CAPITALIZE then
						table.insert(output, lower)
					else
						table.insert(output, upper)
					end
				else
					table.insert(output, word)
				end
			else
				-- capitalize the last word of the component
				if i == #seps_words then
					if casing == LEAVE_ALONE then
						table.insert(output, word)
					elseif casing == UPPERCASE then
						table.insert(output, upper)
					else
						table.insert(output, capitalized)
					end
				else
					-- determine how we should capitalize the rest of the words
					if casing == LOWERCASE then
						table.insert(output, lower)
					elseif casing == LEAVE_ALONE then
						table.insert(output, word)
					elseif casing == CAPITALIZE then
						table.insert(output, capitalized)
					else
						table.insert(output, upper)
					end
				end
			end
		end
	end
	-- append remaining non-word chars
	table.insert(output, input:match([[([^\pL\pN]*)$]]))
	return table.concat(output)
end

--	standardize punctuation
-----
local function fix_punctuation(input)
	-- convert spacing to one single space
	input = input:gsub([[\s+]], ' ')

	-- trim prefix and suffix space
	input = input:gsub([[^\s+]], '')
	input = input:gsub([[\s+$]], '')

	return input
end

------------------
-- DO THE STUFF --
------------------

-- capitalize components, and reassemble them into tags
for tag, _ in pairs(tags) do
	if components[tag] then
		debug('> assembling ' .. tag)
		tags[tag] = ''
		for i, _ in ipairs(components[tag]) do
			comp = components[tag][i]
			if comp.capitalize then
				tags[tag] = tags[tag] .. setcase(comp.component)
			else
				tags[tag] = tags[tag] .. comp.component
			end
		end
		debug(tags[tag])
	end
end

-- apply global substitutions
for k, _ in pairs(tags) do
	for _, rule in ipairs(tag_settings.global_substitutions) do
		newtag = tags[k]:gsub(rule[1], rule[2])
		if newtag ~= tags[k] then
			debug("> performing global substitution on " .. k .. ": '" .. rule[1] .. "' -> '" .. rule[2] .. "'")
			tags[k] = newtag
			debug(tags[k])
		end
	end
end

-- fix punctuation
for k, v in pairs(tags) do
	tags[k] = fix_punctuation(v)
end

-- replace all tags
output.tags = tags
