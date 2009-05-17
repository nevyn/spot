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

class Despotify::Session
	# spotify:user:chripppa:playlist:6EUwMKcf7weEP4JsLmKJKR
	# spotify:track:26b0ZNVmaWQWuKAEchHog5
	# spotify:search:mono
	# spotify:artist:2sDfbgbPqK8cnEDV5bCyby
	# spotify:album:2SfDMhAX5dmall6oGPGtp5
	def uri(uri)
		args = uri.split ':'

		return if args[0] != 'spotify'

		cmd = args[1]

		if cmd == 'user'
			if args[3] == 'playlist' and args[4].length == 22
				return Despotify::Playlist.new(self, Despotify.uri2id(args[4]) + '02')
			end
		elsif cmd == 'track'
		elsif cmd == 'search'
			return search(args[2])
		elsif cmd == 'artist'
			if args[2].length == 22
				return Despotify::Artist.new(self, Despotify.uri2id(args[2]))
			end
		elsif cmd == 'album'
			if args[2].length == 22
				return Despotify::Album.new(self, Despotify.uri2id(args[2]))
			end
		end
	end
end

def testuri(uri)
	puts '%s => %s' % [uri, @despotify.uri(uri).inspect]
end

testuri 'spotify:user:chripppa:playlist:6EUwMKcf7weEP4JsLmKJKR'
testuri 'spotify:search:mono'
testuri 'spotify:artist:2sDfbgbPqK8cnEDV5bCyby'
testuri 'spotify:album:2SfDMhAX5dmall6oGPGtp5'
testuri 'spotify:track:26b0ZNVmaWQWuKAEchHog5'
