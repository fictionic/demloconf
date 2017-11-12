------------------
-- 01: PROFILES --
------------------

-- flac preset
---------------------------------

-- library: 'hi-res', 'lo-res', or nil
library_dir = nil

-- remove source, cuz we don't want wav files
output.rmsrc = true

-- encoding map: * -> flac
encoding_map = {
	{
		'.*',
		{
			['format'] = 'flac',
			['parameters'] = {'-c:a', 'flac', '-aq', '8'}
		}
	},
}

-- types of cover art to use
cover_types = {}

-- downscale ultra-high-res covers
COVER_LIMIT_HIGH = nil

-- apply minimal path substitutions
pathsubs = default_pathsubs
