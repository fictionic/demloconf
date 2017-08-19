--------------------------
-- 00: GLOBALS/SETTINGS --
--------------------------

-- root of audio library
library_location = "/home/dylan/audio/library/"

-- cover art options
PORTABLE_COVER_SIZE_LIMIT = 300
LOCAL_COVER_SIZE_LIMIT = 20000

-- rules for encoding:
-- association between input_format and {output_format, output_parameters}
-- (set output_format = nil to use input format)
default_encoding_map = {
	['.*'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}

-- substitutions to make in filepaths:
default_pathsubs = {
	["/"] = ","
}
strict_pathsubs = {
	["/"] = ",",
	[ [[\\]] ] = ",",
	[":"] = ';',
	[ [=[[<>"|?*]]=] ] = "-",
}

-- global utility function
empty = function (s)
	return type(s) ~= 'string' or s == ''
end

-- tag contents settings --
---------------------------

tag_settings = {}

-- substitutions to make in tags
tag_settings.global_substitutions = {
	-- replace various type of single quotes by "'"
	{'[´`’]', "'"},
	-- replace ellipsis character with three dots
	{'…','...'},
}
if globsubs ~= nil then
	for _, sub in ipairs(globsubs) do
		table.insert(tag_settings.global_substitutions, sub)
	end
end
if sub ~= nil then
	sub = {sub:match([=[s/(.+?[^/])/(.+)]=])}
	sub[1] = sub[1]:gsub([[\\/]], "/") 
	-- ^ this weird stuff is to allow for escaped forward slashes in the search pattern
	table.insert(tag_settings.global_substitutions, sub)
end

-- capitalization scheme
-- options: 'titlecase', 'sentencecase', 'easy'
-- - 'titlecase' = capitalize the first and last words,
--                 and all 'important' words, of every
--                 'title component' of a tag
--                 (see 11-tag-contents.lua)
-- - 'sentencecase' = capitalize the first word of
--                    every 'title component' of a tag
--                    (see 11-tag-contents.lua)
-- - 'easy' = capitalize the first letter of every word
--            of a tag, no questions asked
tag_settings.casing = 'titlecase'

-- should parenthetical "indications" be capitalized in song titles?
-- e.g. "Lapse (instrumental)" vs "Lapse (Instrumental)"
tag_settings.capitalize_title_indications = false

-- should parentheticals "indications" be capitalized in album titles?
-- e.g. "Havoc (special edition)" vs "Havoc (Special Edition)"
tag_settings.capitalize_album_indications = true

-- indicate featured performer in artist tag rather than title tag
-- (invoking the distinction between artist and album artist)
tag_settings.featured_performer_in_artist = false

-- how featured performers should be introduced.
-- common choices are "Feat.", "Ft.", "ft", etc
tag_settings.featured_performer_format = 'feat.'

-- how parts of works should be indicated
tag_settings.uni_multipart_unnamed_format = '%title%, %part_type% %index%'
tag_settings.uni_multipart_named_format = '%title%, %part_type% %index%: %subtitle%'
tag_settings.multi_multipart_format = '%title%, %part_type% %indeces%'
-- whether to use roman numerals for part numbers (rather than arabic numerals)
tag_settings.part_index_use_roman = true
-- format for part type names
tag_settings.part_type_name_format = {
	-- Pt vs Part
	['abbreviate'] = true,
	-- Pt. vs Pt
	['dot'] = true,
	-- Pt vs pt
	['capitalize'] = true
}

-- types of delimiters to use for various features
tag_settings.parenthetical_feature_delimiters = {
	-- - in artist/album/title
	['parenthetical_featured_performer'] = '[]',
	-- - in title
	['parenthetical_alternate_mix_indication'] = '()',
	['parenthetical_alternate_recording_indication'] = '()',
	['parenthetical_alternate_version_indication'] = '()',
	['parenthetical_cover_indication'] = '[]',
	['parenthetical_instrumental_indication'] = '()',
	['parenthetical_reprise_indication'] = '()',
	-- - in album
	['parenthetical_single_indication'] = '[]',
	['parenthetical_disc_indication'] = '[]',
	['parenthetical_alternate_edition_indication'] = '()',
	['parenthetical_subtitle'] = '()',
}

-- words that should be lowercase unless at the start or end of a component
-- OR if preceded by certain words, as to make them not be prepositions
-- but rather parts of multi-word verbs
-- (most auto-titlecase utilties get this wrong)
tag_settings.const_preposition = {
	['to'] = {},
	['with'] = {},
	['of'] = {},
	['from'] = {},
	['on'] = {'come', 'move'},
	['in'] = {'plug', 'breathe', 'breathing'},
	['into'] = {},
	['at'] = {},
	['by'] = {},
	['for'] = {},
	['as'] = {},
	['via'] = {},
}

-- words that should always be uppercase
tag_settings.const_upper = const_upper or {
	'OK',
	'DVD',
	'CD',
	'TV',
}

-- words that should always be lowercase
-- unless at the start or end of a component
tag_settings.const_lower = const_lower or {
-- articles
	'the',
	'a',
	'an',
-- coordinating conjunctions
	'and',
	'if',
	'but',
	'or',
	'nor',
	'so',
-- misc
	'vs',
-- spanish
	'la',
	'el',
	'del',
	'al',
-- other
	'à',
}

-- PER-USE TOGGLABLES --
------------------------

-- keep all-caps words as they are?
tag_settings.keep_all_caps = true
if keepcaps ~= nil then tag_settings.keep_all_caps = keepcaps end

-- keep mixed-case words as they are?
tag_settings.keep_mixed_case = true
if keepmixed ~= nil then tag_settings.keep_mixed_case = keepmixed end

