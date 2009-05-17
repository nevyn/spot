#!/usr/bin/env python
# vim: set fileencoding=utf-8 :
# Simple test to show how Spytify works.
# Copyright Jørgen P. Tjernø <jorgen@devsoft.no>

from getpass import getpass
import random
import sys
import time

import spytify

def print_track(track):
    has_metadata = "un"
    if track.has_meta_data():
        has_metadata = ""

    print "  > %s - %s (%s), length: %d [%splayable]" % (", ".join((a.name for a in track.artists)),
                                                         track.title, track.album,
                                                         track.length, has_metadata)

def main():
    username = raw_input("Enter your username: ").strip()

    if not username:
        print >>sys.stderr, "Empty username, exiting."
        sys.exit(1)

    password = getpass("Enter your password: ").strip()
    if not password:
        print >>sys.stderr, "Empty password, exiting."
        sys.exit(1)

    s = spytify.Spytify(username, password)

    print "Enter searchterm: (blank for foo) "
    searchterm = sys.stdin.readline().strip()
    if not searchterm:
        searchterm = "foo"

    print "\nStored playlists:"
    playlists = s.stored_playlists
    for playlist in playlists:
        print " %s, by %s" % (playlist.name, playlist.author)
        for track in playlist.tracks:
            print_track(track)

    sr = s.search(searchterm)

    print "\nSearch:"
    if not sr:
        print "No search hits."
    else:
        print " Search: %s (suggested: %s)" % (sr.query, sr.suggestion)
        for track in sr.playlist.tracks:
            print_track(track)

        random_track = random.choice(sr.playlist.tracks)
        print "Playing %s" % random_track
        s.play(random_track)

        time.sleep(10)

        print "Pausing."
        s.pause()
        time.sleep(2)

        print "Aaaand back again."
        s.resume()

        time.sleep(5)

    s.close()

if __name__ == '__main__':
    main()
