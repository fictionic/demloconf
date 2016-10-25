library_dir = 'lo-res'
COVER_LIMIT_HIGH = 300
cover_types = {"front"}
encoding_map = { -- input_format -> {output_format, output_parameters}
	['flac'] = {
		['format'] = 'ogg',
		['parameters'] = {'-c:a', 'libvorbis', '-q:a', '5'}
	},
	['mp3|mp4|m4a|ogg'] = {
		['format'] = nil,
		['parameters'] = {'-c:a', 'copy'}
	}
}
pathsubs = {
	["/"] = ",",
	[ [[\\]] ] = ",",
	[":"] = ';',
	[ [=[[<>"|?*]]=] ] = "-",
}
