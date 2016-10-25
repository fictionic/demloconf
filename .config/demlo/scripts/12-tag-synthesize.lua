------------------------------------
--	STANDARDIZE TAGS
------------------------------------

debug(">> STANDARDIZING TAGS")

empty = empty or function (s)
	return (type(s) ~= 'string' or s == '')
end

-- analyze & fix composer
if not empty(tags.composer) then
	-- fix redundant composer
	if tags.composer == tags.artist then
		tags.composer = nil
	else
		-- if composer is made up of semicolon-separated names,
		-- change the semicolons to commas
		tags.composer = tags.composer
		if string.match(tags.composer, "^(?:[^;]+; )+[^;]+$") then
			tags.composer = tags.composer:gsub(";", ",")
		end
	end
end

--	standardize case
------------------------------------

-- global options.
local sentencecase = scase or false

-- rules for simple global substitution through all tags
local subst = {
	-- replace various type of single quotes by "'".
	{'[´`’]', "'"},
}

-- words that should always be lowercase
-- unless at the start or end of a component
const_lower = const_lower or {
	'the',
	'a',
	'and',
	'if',
	'but',
	'an',
	'so',
	'as',
	'or',
	'nor',
	'vs',
	'via',
 -- spanish
	'la',
	'el',
	'del',
	'al',
-- other
	'à',
}

-- words that should be lowercase unless
-- at the start or end of a component OR
-- if preceded by certain words, as to
-- make them not be prepositions
const_preposition = {
	['to'] = {},
	['with'] = {},
	['of'] = {},
	['from'] = {},
	['on'] = {'come', 'move'},
	['in'] = {'plug', 'breathe', 'breathing'},
	['at'] = {},
	['by'] = {},
	['for'] = {},
}

-- words that should always be uppercase
const_upper = const_upper or {
	'OK',
	'DVD',
	'CD',
}

-- casing options
local LEAVE_ALONE = 0
local LOWERCASE = 1
local CAPITALIZE = 2
local UPPERCASE = 3

-- Constants are written as provided, except if they begin a component, in which
-- case the first letter is uppercase, or, if sentencecase is not set, if they
-- end a component.
--
-- When sentencecase is set to true, only the first letter of every component will
-- be capitalized, the other words that are not subject to the rules will be
-- lowercase.
--
-- This script was inspired by http://www.pement.org/awk/titlecase.awk.txt.
local function setcase(input, sentencecase)
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
			for _, c in ipairs(const_lower) do
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
			for c, list in pairs(const_preposition) do
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
			for _, c in ipairs(const_upper) do
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

		-- Words that are at least 2 characters long and already all-caps
		if not matched and word:match('^[[:upper:]]{2,}$') then
			debug("matched all-caps word: '" .. word .. "'")
			casing = LEAVE_ALONE
		end

		-- Words that are longer than 2 characters and already mixed-case
		if not matched and word:match('(?:.+?[[:upper:]][[:lower:]]|[[:lower:]]+?[[:upper:]])') then
			debug("matched mixed-case word: '" .. word .. "'")
			casing = LEAVE_ALONE
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
	for _, rule in ipairs(subst) do
		tags[k] = tags[k]:gsub(rule[1], rule[2])
	end
end

-- fix punctuation
for k, v in pairs(tags) do
	tags[k] = fix_punctuation(v)
end

-- replace all tags
output.tags = tags
o = output.tags
