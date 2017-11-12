------------------
-- 01: PROFILES --
------------------

-- convert to MP3 V0, plain and simple
--------------------------------------

-- don't put it in a library
library_dir = nil

-- keep original files
output.rmsrc = false

-- encode to MP3 V0
encoding_map = {
	{
		'.*',
		{
			['format'] = 'mp3',
			['parameters'] = {'-aq', '0'}
		}
	}
}

-- only use front cover
cover_types = {"front"}

-- keep high-res covers
COVER_LIMIT_HIGH = LOCAL_COVER_SIZE_LIMIT

-- apply strict pathsubs
pathsubs = strict_pathsubs
