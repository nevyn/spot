#!/usr/bin/env ruby

$LOAD_PATH << '../build'

require 'despotify'
require 'pp'


class Simple < Despotify::Session
	def initialize
		puts 'init'

		super
	end
end

class SuperPlaylist < Despotify::Playlist
	def dump
		tracks.each do |track|
			pp track.metadata
		end
	end
end



username = ARGV.shift
password = ARGV.shift

if not (username and password)
	puts 'Need username & password'
	exit
end

despotify = Simple.new
begin
	despotify.authenticate(username, password)
rescue Despotify::DespotifyError
	puts 'Failed to authenticate user: %s' % despotify.get_error
	exit
end

pls = SuperPlaylist.new(despotify, 'd10d32140807f5260d045384117734c002')
pls.dump
