------------------
-- 01: PROFILES --
------------------

-- default profile (for tagging)
---------------------------------

-- library: 'hi-res', 'lo-res', or nil
library_dir = nil

-- remove source, so we don't have extra files 
output.rmsrc = true

-- rules for encoding:
-- association between input_format and {output_format, output_parameters}
-- (set output_format = nil to use input format)
encoding_map = default_encoding_map

-- types of cover art to use
cover_types = {}

-- upper limit for vertical resolution of cover art
COVER_LIMIT_HIGH = nil

-- apply minimal path substitutions
pathsubs = default_pathsubs
