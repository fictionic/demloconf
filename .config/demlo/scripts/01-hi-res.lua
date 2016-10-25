library_dir = 'hi-res'
COVER_LIMIT_HIGH = 20000
cover_types = {"front", "back", "other"}
encoding_map = {
	['.*'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}
pathsubs = {
	["/"] = ","
}
