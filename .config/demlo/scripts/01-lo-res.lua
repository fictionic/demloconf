------------------
-- 01: PROFILES --
------------------

-- low resolution library preset
--------------------------------

-- import to lo-res library
settings.library.sublibrary = 'lo-res'

-- keep original files
output.rmsrc = false

-- flac -> vorbis q5; lossy -> copy
settings.encode.map = {
	{
		'flac',
		{
			['format'] = 'ogg',
			['parameters'] = {'-c:a', 'libvorbis', '-q:a', '5'}
		}
	},
	{
		'mp3|mp4|m4a|ogg',
		{
			['format'] = nil,
			['parameters'] = {'-c:a', 'copy'}
		}
	}
}

-- only use front cover
settings.cover.types = {"front"}

-- downscale covers to 300x300
settings.cover.size_limit = settings.cover.size_limit_portable

-- apply strict pathsubs
settings.path.substitutions = settings.path.strict_substitutions
