library_dir = nil
COVER_LIMIT_HIGH = nil
cover_types = {}
output.rmsrc = true
encoding_map = { -- input_format -> {output_format, output_parameters}
	['.*'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}
pathsubs = {
	["/"] = ","
}
