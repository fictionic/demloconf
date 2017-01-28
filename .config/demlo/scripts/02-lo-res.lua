library_dir = 'lo-res'
COVER_LIMIT_HIGH = 300
cover_types = {"front"}
output.rmsrc = false
encoding_map = {
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
