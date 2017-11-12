---------------------
-- 30: OUTPUT PATH --
---------------------

debug([[//=============\\]])
debug([[|| 32-path.lua ||]])
debug([[\\=============//]])

-- get basename and directory in case those scripts weren't run
basename = name or basename
if basename == nil then
	debug("using old basename...")
	basename = input.path:match("^.+?/([^/]+)\\.[^.]+$")
end
directory = dir or directory
if directory == nil then
	debug("using old directory...")
	directory = input.path:match("^(.+?/)[^/]+\\.[^.]+$")
end

-- set extension based on format
local extension = ext or output.format
if ext then
	debug("using given extension: '" .. ext .. "'")
else
	if extension == 'mp4' then
		extension = 'm4a'
	end
	debug("computed extension from output format: '" .. extension .. "'")
end

-- set output.path
output.path = directory .. basename .. '.' .. extension
