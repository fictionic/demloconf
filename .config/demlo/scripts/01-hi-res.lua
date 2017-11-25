------------------
-- 01: PROFILES --
------------------

-- high resolution library preset
---------------------------------

-- import to hi-res library
settings.library.sublibrary = 'hi-res'

-- don't keep original files
output.rmsrc = true

-- lossless -> flac, lossy -> copy
settings.encode.map = {
	{
		'(wav|flac)',
		{
			['format'] = 'flac',
			['parameters'] = {'-c:a', 'flac', '-aq', '8'}
		}
	},
	{
		'.*',
		{
			['format'] = nil,
			['parameters'] = {'-c:a', 'copy'} 
		}
	}
}

-- use all cover types
settings.cover.types = settings.cover.types_all

-- downscale ultra-high-res covers
settings.cover.size_limit = settings.cover.size_limit_local

-- apply minimal path substitutions
settings.path.substitutions = settings.path.default_substitutions
