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

-- substitutions to make in tags
tags_global_substitutions = {
	-- replace various type of single quotes by "'"
	{'[´`’]', "'"},
}

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
casing = 'titlecase'

-- indicate featured performer in artist tag rather than title tag
-- (invoking the distinction between artist and album artist)
featured_performer_in_artist = false

-- types of delimiters to use for various features
parenthetical_feature_delimiters = {
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
const_preposition = {
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
const_upper = const_upper or {
	'OK',
	'DVD',
	'CD',
	'TV',
}

-- words that should always be lowercase
-- unless at the start or end of a component
const_lower = const_lower or {
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

