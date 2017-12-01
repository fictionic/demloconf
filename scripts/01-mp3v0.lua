------------------
-- 01: PROFILES --
------------------

-- convert to MP3 V0, plain and simple
--------------------------------------

-- don't put it in a library
settings.library.sublibrary = nil

-- keep original files
output.rmsrc = false

-- encode to MP3 V0
settings.encode.map = {
	{
		'.*',
		{
			['format'] = 'mp3',
			['parameters'] = {'-aq', '0'}
		}
	}
}

-- only use front cover
settings.cover.types = {"front"}

-- keep high-res covers
settings.cover.size_limit = settings.cover.size_limit_portable

-- apply strict pathsubs
settings.path.substitutions = settings.path.strict_substitutions
