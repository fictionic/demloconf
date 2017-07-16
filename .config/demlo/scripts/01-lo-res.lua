------------------
-- 01: PROFILES --
------------------

-- low resolution library preset
--------------------------------

-- import to lo-res library
library_dir = 'lo-res'
-- keep original files
output.rmsrc = false
-- flac -> vorbis q5; lossy -> copy
encoding_map = {
	['flac'] = {
		['format'] = 'ogg',
		['parameters'] = {'-c:a', 'libvorbis', '-q:a', '5'}
	},
	['mp3|mp4|m4a|ogg'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}
-- only use front cover
cover_types = {"front"}
-- downscale covers to 300x300
COVER_LIMIT_HIGH = PORTABLE_COVER_SIZE_LIMIT
-- apply strict pathsubs
pathsubs = strict_pathsubs
