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

album = Despotify::Album.new(despotify, 'c4ee36e89d3a45cb98c44159ab04dc66')

pp album.name
pp album.metadata
