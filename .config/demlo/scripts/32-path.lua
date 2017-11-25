---------------------
-- 30: OUTPUT PATH --
---------------------

debug([[//=============\\]])
debug([[|| 32-path.lua ||]])
debug([[\\=============//]])

-- get basename and directory in case those scripts weren't run
local basename = settings.path.basename
if empty(basename) then
	debug("using input basename")
	basename = input_basename
end
local directory = settings.path.directory
if empty(directory) then
	debug("using input directory")
	directory = input_directory
end

-- set extension based on format
local extension = settings.path.extension
if ext then
	extension = ext
	debug("using given extension: '" .. ext .. "'")
else
	-- use m4a extension for all mp4-related formats
	if output.format:match('mov|mp4|m4a|3gp|3g2|mj2') then
		extension = 'm4a'
	else
		extension = output.format
	end
	debug("computed extension from output format: '" .. extension .. "'")
end

-- set output.path
output.path = directory .. '/' .. basename .. '.' .. extension
debug("> output path: " .. output.path)
