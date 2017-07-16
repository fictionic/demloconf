---------------------
-- 30: OUTPUT PATH --
---------------------

-- debug([[//=============\\]])
-- debug([[|| 32-path.lua ||]])
-- debug([[\\=============//]])

-- set extension based on format
local extension = extension or output.format

-- extract default directory, basename from input path
local directory_default, basename_default = input.path:match("^(.+?/)([^/]+)\\.[^.]+$")

if empty(directory) then
	directory = directory_default
end
if empty(basename) then
	basename = basename_default
end

-- put ending slash in user-entered directory, if present
directory = directory:gsub("/$","") .. "/" or "./"

-- set output.path
output.path = directory .. basename .. '.' .. extension
