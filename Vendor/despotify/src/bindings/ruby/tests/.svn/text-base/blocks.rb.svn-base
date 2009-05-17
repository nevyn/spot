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

Despotify::Session.new do |despotify|
	pp despotify

	begin
		despotify.authenticate(username, password)
	rescue Despotify::DespotifyError
		puts 'Failed to authenticate user: %s' % despotify.get_error
		exit
	end

	despotify.playlist 'd10d32140807f5260d045384117734c002' do |playlist|
		pp playlist
	end

	despotify.artist '691a84294bfb4883a2124099bf1d0a8c' do |artist|
		pp artist
	end

	despotify.album 'c4ee36e89d3a45cb98c44159ab04dc66' do |album|
		pp album
	end

	despotify.search 'machinae' do |search|
		pp search
	end
end
