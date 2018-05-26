-- Demlo configuration file (Lua)

-- No colors by default since it may not work on all terminals.
Color = true

-- Number of cores to use (0 for all).
Cores = 0

-- Path to 'exist' action, i.e. what to do when destination exists. Set
-- 'output.write' to "over", "skip", or anything else for appending a random
-- suffix to the file name.
Exist = ''

-- Extensions to look for when a folder is browsed.
Extensions = {}
ext = {'flac', 'mp3', 'm4a', 'ogg', 'mp4', 'ac3', 'aac', 'wma', 'wav'}
for _, v in ipairs(ext) do
	Extensions[v]=true
end

-- Fetch cover from an online database.
Getcover = false

-- Fetch tags from an online database.
Gettags = false

-- Lua code to run before and after the other scripts, respectively.
Prescript = ''
Postscript = ''

-- If false, show preview and exit before processing.
Process = false

-- Scripts to run by default.
-- Demlo will run them in lexicographic order.
-- Order matters, e.g. 'path' can be influenced by the modifications made by 'tag'.
Scripts = {'000-util', '001-globals', '01-default', '10-tag-fields', '11-tag-contents', '20-encode', '30-basename', '31-directory', '32-path', '40-cover'}
