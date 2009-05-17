#!/usr/bin/env ruby
# $Id: extconf.rb 266 2009-03-27 02:36:26Z chripppa $

require 'mkmf'

# Give it a name
extension_name = 'despotify'

print 'Checking for despotify..'

# find despotify lib
if pkg_config 'despotify' then
	puts ' yes'
else
	puts ' no'
	puts 'You need to have the despotify library installed to build'
	exit
end

# The destination
dir_config(extension_name)

# Do the work
create_makefile(extension_name, '../ext')
