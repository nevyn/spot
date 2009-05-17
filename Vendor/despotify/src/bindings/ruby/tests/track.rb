#!/usr/bin/env ruby

$LOAD_PATH << '../build'

require 'despotify'
require 'pp'

username = ARGV.shift
password = ARGV.shift

if not (username and password)
	puts 'Need username & password'
	exit
end

@despotify = Despotify::Session.new
begin
	@despotify.authenticate(username, password)
rescue Despotify::DespotifyError
	puts 'Failed to authenticate user: %s' % @despotify.get_error
	exit
end

def dump_cover(track, filename)
	coverid  = track['cover_id']
	image = @despotify.get_image(coverid)

	f = File.new(filename, 'w')
	f.write(image)
	f.close
end

pls = @despotify.search('machinae')
track = pls.tracks[0]

pp track.metadata
pp track.metadata.object_id
pp track.metadata.object_id

#dump_cover(track, 'test.jpg')
