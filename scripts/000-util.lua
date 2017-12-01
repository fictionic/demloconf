----------------------------- UTILITY FUNCTIONS ----------------------------

-- check whether a variable is empty
empty = function (s)
	return type(s) ~= 'string' or s == ''
end

-- print a string representation of a value
function to_str(item)
	if type(item) == 'table' then
		local item_str = '{'
		if #item > 0 then
			for i, val in ipairs(item) do
				item_str = item_str .. to_str(val)
				if i < #item then
					item_str = item_str .. ', '
				else
					item_str = item_str .. '}'
				end
			end
		else
			for k, v in pairs(item) do
				local v_str
				if type(v) == 'string' then
					v_str = "'" .. v .. "'"
				end
				item_str = item_str .. "['" .. tostring(k) .. "']=" .. v_str .. ', '
			end
			item_str = item_str:sub(1,#item_str-2) .. '}'
		end
		return item_str
	else
		return tostring(item)
	end
end

-- replace debug() with a more useful function
print = function (item)
	debug(to_str(item))
end

-- concatenate two tables
table_concat = function(orig_table, new_items)
	for i=1, #new_items do
		orig_table[#orig_table+1] = new_items[i]
	end
	return orig_table
end

-- set setting to given user-supplied value
function set_user_value(settings_section, setting, user_value)
	settings[settings_section][setting] = user_value == nil and settings[settings_section][setting] or user_value
end

-- apply path substitutions
function apply_pathsubs(s)
	for bad, good in pairs(settings.path.substitutions) do
		s = s:gsub(bad, good)
	end
	return s
end

-- append a string to a variable, with prefix and suffix, and applying a substitution function
function append_to_and_filter(base, new_portion, before, after, filter)
	if not empty(new_portion) then
		before = before or ''
		after = after or ''
		base = base .. filter(before) .. filter(new_portion) .. filter(after)
	end
	return base
end

