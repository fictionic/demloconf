------------------
-- 01: PROFILES --
------------------

-- high resolution library preset
---------------------------------

-- import to hi-res library
library_dir = 'hi-res'

-- don't keep original files
output.rmsrc = true

-- lossless -> flac, lossy -> copy
encoding_map = {
	['(wav|flac)'] = {
		['format'] = 'flac',
		['parameters'] = {'-c:a', 'flac', '-aq', '8'}
	},
	['.*'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}

-- use all cover types
cover_types = {"front", "back", "other"}

-- downscale ultra-high-res covers
COVER_LIMIT_HIGH = LOCAL_COVER_SIZE_LIMIT

-- apply minimal path substitutions
pathsubs = default_pathsubs
