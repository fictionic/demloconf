--------------------------
-- 00: GLOBALS/SETTINGS --
--------------------------

settings = {}

---------------------------------- LIBRARY ---------------------------------

settings.library = {}

-- root of audio library
settings.library.location = "/home/dylan/audio/library/"
-- sublibrary name
settings.library.sublibrary = nil

----------------------------------- COVER ----------------------------------

settings.cover = {}

-- types of art images to look for
settings.cover.types = nil
settings.cover.types_all = {"front", "back", "other"}
-- size limits for cover art files (profile must set to int)
settings.cover.size_limit = nil
settings.cover.size_limit_portable = 300
settings.cover.size_limit_local = 20000

---------------------------------- ENCODE ----------------------------------

settings.encode = {}

-- association between input_format and {output_format, output_parameters}
settings.encode.map = nil
-- (set output_format = nil to use input format)
settings.encode.default_map = {
	{
		'.*',
		{
			['format'] = nil,
			['parameters'] = {'-c:a', 'copy'}
		}
	}
}

-- override encoding parameters
settings.encode.override_parameters = nil

-- append encoding parameters
settings.encode.append_paremeters = nil

---------------------
-- user values
---------------------
set_user_value('encode', 'override_parameters', oparams)
set_user_value('encode', 'append_parameters', aparams)

----------------------------------- PATH -----------------------------------

settings.path = {}

-- extract the input path components so we only compute them once
input_basename = input.path:match("^.+?/([^/]+)\\.[^.]+$")
input_directory = input.path:match("^(.+?/)[^/]+\\.[^.]+$")

-- path components (empty = compute automatically)
-- name of output file (without extension)
settings.path.basename = ''
-- parent directory of output file
settings.path.directory = ''
-- extension of output file
settings.path.extension = ''
-- substitutions to make in filepaths
settings.path.substitutions = nil
-- for Linux, Mac, etc
settings.path.default_substitutions = {
	["/"] = ","
}
-- for Windows, FAT32, etc
settings.path.strict_substitutions = {
	["/"] = ",",
	[ [[\\]] ] = ",",
	[":"] = ';',
	[ [=[[<>"|?*]]=] ] = "-",
}

---------------------
-- user values
---------------------

-- path components
set_user_value('path', 'basename', name)
set_user_value('path', 'directory', dir)
set_user_value('path', 'extension', ext)

-- path substitutions
if psubs ~= nil then
	for _, sub in ipairs(psubs) do
		table.insert(settings.path.default_substitutions, sub)
	end
elseif psub ~= nil then
	psub = {psub:match([=[s/((?:[^/]|\/)+)/((?:[^/]|\/)+)(?:/g?)?]=])}
	psub[1] = psub[1]:gsub([[\\/]], "/")
	psub[2] = psub[2]:gsub([[\\/]], "/")
	-- ^ this weird stuff is to allow for escaped forward slashes
	settings.path.default_substitutions[psub[1]] = psub[2]
end

------------------------------------ TAG -----------------------------------

settings.tag = {}

-- substitutions to make in tags
settings.tag.global_substitutions = {
	-- replace various type of single quotes by "'"
	{'[´`’]', "'"},
	-- replace ellipsis character with three dots
	{'…','...'},
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
settings.tag.casing = 'titlecase'

-- should parenthetical "indications" be capitalized in song titles?
-- e.g. "Lapse (instrumental)" vs "Lapse (Instrumental)"
settings.tag.capitalize_title_indications = false

-- should parentheticals "indications" be capitalized in album titles?
-- e.g. "Havoc (special edition)" vs "Havoc (Special Edition)"
settings.tag.capitalize_album_indications = true

-- indicate featured performer in artist tag rather than title tag
-- (invoking the distinction between artist and album artist)
settings.tag.featured_performer_in_artist = false

-- how featured performers should be introduced.
-- common choices are "Feat.", "Ft.", "ft", etc
settings.tag.featured_performer_format = 'feat.'

-- how parts of works should be indicated (doesn't work yet; not sure if it should work this way)
settings.tag.uni_multipart_format = '%title%, %part_type% %index%: %subtitle%'
settings.tag.multi_multipart_format = '%title%, %part_type% %indeces%'
-- recognized part type names
settings.tag.uni_part_types = {
	['(?i:pt\\.?|part)'] = 'Pt.',
	['(?i:vol\\.?|volume)'] = 'Vol.',
	['(?i:ch\\.?|chapter)'] = 'Ch.',
	['(?i:book)'] = 'Book',
	['(?i:phase)'] = 'Phase'
}
settings.tag.multi_part_types = {
	['(?i:pts?\\.?|parts?)'] = 'Pts.',
	['(?i:vols?\\.?|volumes?)'] = 'Vols.',
	['(?:books?)'] = 'Books',
}
-- whether to use roman numerals for part numbers (rather than arabic numerals)
settings.tag.part_index_use_roman = true

-- types of delimiters to use for various features
settings.tag.parenthetical_feature_delimiters = {
	-- - in artist/album/title
	['parenthetical_featured_performer'] = '[',
	-- - in title
	['parenthetical_alternate_mix_indication'] = '(',
	['parenthetical_alternate_recording_indication'] = '(',
	['parenthetical_alternate_version_indication'] = '(',
	['parenthetical_cover_indication'] = '[',
	['parenthetical_instrumental_indication'] = '(',
	['parenthetical_reprise_indication'] = '(',
	-- - in album
	['parenthetical_single_indication'] = '[',
	['parenthetical_disc_indication'] = '[',
	['parenthetical_alternate_edition_indication'] = '(',
	['parenthetical_subtitle'] = '(',
}

-- words that should be lowercase unless at the start or end of a component
-- OR if preceded by certain words, as to make them not be prepositions
-- but rather parts of multi-word verbs
-- (most auto-titlecase utilties get this wrong)
settings.tag.const_preposition = {
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
settings.tag.const_upper = {
	'OK',
	'DVD',
	'CD',
	'TV',
}

-- words that should always be lowercase
-- unless at the start or end of a component
settings.tag.const_lower = {
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

-- keep all-caps words as they are?
settings.tag.keep_all_caps = true

-- keep all-lowercase words as they are?
settings.tag.keep_all_lower = false

-- keep mixed-case words as they are?
settings.tag.keep_mixed_case = true

-- always overwrite existing tags with filename-extracted ones? if so, which?
-- accepted values: 'all', '<tag>', '<tag1>,<tag2>,...'
settings.tag.extract_tags = true
settings.tag.force_extract = nil

---------------------
-- user values
---------------------

-- settings.tag.casing <-- tcase
set_user_value('tag', 'casing', tcase)

-- keep capitization styles
set_user_value('tag', 'keep_all_caps', keepupper)
set_user_value('tag', 'keep_mixed_case', keepmixed)
set_user_value('tag', 'keep_all_lower', keeplower)

-- extract tags?
set_user_value('tag', 'extract_tags', textr)

-- always use these extracted tags
set_user_value('tag', 'force_extract', ftextr)

-- tag constants
if type(const_lower) == 'table' then
	settings.tag.const_lower = table_concat(settings.tag, const_lower)
end
if type(const_upper) == 'table' then
	settings.tag.const_upper = table_concat(settings.tag, const_upper)
end

-- tag substitutions
if tsubs ~= nil then
	for _, sub in ipairs(globsubs) do
		table.insert(settings.tag.global_substitutions, sub)
	end
elseif tsub ~= nil then
	tsub = {tsub:match([=[s/((?:[^/]|\/)+)/((?:[^/]|\/)+)(?:/g?)?]=])}
	tsub[1] = tsub[1]:gsub([[\\/]], "/")
	tsub[2] = tsub[2]:gsub([[\\/]], "/")
	-- ^ this weird stuff is to allow for escaped forward slashes
	table.insert(settings.tag.global_substitutions, tsub)
end
