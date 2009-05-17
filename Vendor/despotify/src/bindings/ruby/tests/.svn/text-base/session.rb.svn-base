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

pls = despotify.playlist 'd10d32140807f5260d045384117734c002'
pp pls

pp despotify.user_info
