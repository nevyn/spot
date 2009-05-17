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

despotify = Despotify::Session.new
begin
	despotify.authenticate(username, password)
rescue Despotify::DespotifyError
	puts 'Failed to authenticate user: %s' % despotify.get_error
	exit
end

pls = despotify.search 'machinae'
track = pls.tracks[2]

pp track.metadata

pp despotify.current_track

puts 'Playing'
puts despotify.play(pls, track)
pp despotify.current_track

sleep 5

puts 'Pausing'
puts despotify.pause

sleep 2

puts 'Resuming'
puts despotify.resume

sleep 2

puts 'Stopping'
puts despotify.stop
