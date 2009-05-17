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
	puts 'Failed to authenticate user: %s' % @despotify.get_error
	exit
end

search = despotify.search 'britney spears'
searchtimes = (search.search_info['total_tracks'].to_f / Despotify::MAX_SEARCH_RESULTS).ceil
searchtimes.times { search.search_more }

pp search.tracks.size
