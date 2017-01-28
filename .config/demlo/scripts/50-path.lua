empty = empty or function (s)
	if type(s) ~= 'string' or s == '' then
		return true
	else
		return false
	end
end

--
-- set extension based on format
local ext = ext or (empty(output.format) and input.format.format_name or output.format)
if ext == 'mp4' then ext = 'm4a' end

-- extract default directory, basename from input path
local directory_default, basename_default = input.path:match("^(.+?/)([^/]+)\\.[^.]+$")

if empty(directory) then
	directory = directory_default
end
if empty(basename) then
	basename = basename_default
end

-- set output.path
output.path = directory .. basename .. '.' .. ext
