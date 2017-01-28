library_dir = 'hi-res'
COVER_LIMIT_HIGH = 20000
cover_types = {"front", "back", "other"}
output.rmsrc = true
encoding_map = {
	['wav'] = {
		['format'] = 'flac',
		['parameters'] = {'-c:a', 'flac', '-aq', '8'}
	},
	['.*'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}
pathsubs = {
	["/"] = ","
}
