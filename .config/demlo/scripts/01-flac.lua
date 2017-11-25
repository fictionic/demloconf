------------------
-- 01: PROFILES --
------------------

-- flac preset
---------------------------------

-- library: 'hi-res', 'lo-res', or nil
settings.library.sublibrary = nil

-- remove source, cuz we don't want wav files
output.rmsrc = true

-- encoding map: * -> fully-compressed CD-resolution flac
settings.encode.map = {
	{
		'.*',
		{
			['format'] = 'flac',
			['parameters'] = {'-c:a', 'flac', '-aq', '8', '-sample_fmt', 's16', '-ar', '44100'}
		}
	},
}

-- use all cover types
settings.cover.types = settings.cover.types_all

-- downscale ultra-high-res covers
settings.cover.size_limit = settings.cover.size_limit_local

-- apply minimal path substitutions
settings.path.substitutions = settings.path.default_substitutions
