------------------
-- 01: PROFILES --
------------------

-- default profile (for tagging)
---------------------------------

-- library: 'hi-res', 'lo-res', or nil
settings.library.sublibrary = nil

-- remove source, so we don't have extra files 
output.rmsrc = true

-- rules for encoding:
-- association between input_format and {output_format, output_parameters}
-- (set output_format = nil to use input format)
settings.encode.map = settings.encode.default_map

-- types of cover art to use
settings.cover.types = settings.cover.types_all

-- upper limit for vertical resolution of cover art (nil = no limit)
settings.cover.size_limit = settings.cover.size_limit_local

-- apply minimal path substitutions
settings.path.substitutions = settings.path.default_substitutions
