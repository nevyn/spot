#!/usr/bin/env python
# vim: set fileencoding=utf-8 :
# cambodia.py - a despotified terminal client
#
# License: Do not do to this code that which would anger you if others
#          did it to yours.
#
# Keys:
# Up/Down/PgUp/PgDn  Move focus in lists of playlists and tracks
# Left/Right         Move focus between playlists and tracks
# Enter              Play current playlist starting at focused track
# Backspace          Stop
# Space              Pause/Resume
# Esc                Quit

import spytify

from getpass import getpass
import urwid
import urwid.curses_display

import sys

################################################################################
# Tracks view
class TrackItem(urwid.AttrWrap):
    def __init__(self, track, num):
        self.track = track

        sec = track.length / 1000
        length = '%d:%02d' % (sec / 60, sec % 60)
        if track.has_meta_data():
            widget = self.create_columns(str(num), track.title,
                     '/'.join(a.name for a in track.artists),
                     track.album, length)
            if not track.is_playable():
                widget = urwid.AttrWrap(widget, 'tr-na')
        else:
            widget = urwid.AttrWrap(urwid.Text('Unplayable', wrap = 'clip'), 'tr-na')

        self.__super.__init__(widget, None, 'tr-focus')

    def create_columns(id, title, artist, album, length):
        columns = [
                ('fixed',  3, urwid.Text(id, align = 'right', wrap = 'clip')),
                ('weight', 2, urwid.Text(title, wrap = 'clip')),
                ('weight', 1, urwid.Text(artist, wrap = 'clip')),
                ('weight', 1, urwid.Text(album, wrap = 'clip')),
                ('fixed',  5, urwid.Text(length, align = 'right', wrap = 'clip'))
                ]
        return urwid.Columns(columns, dividechars = 1, min_width = 4)
    create_columns = staticmethod(create_columns)

    def selectable(self):
        return True

    def keypress(self, (maxcol,), key):
        return key

class TrackWalker(urwid.SimpleListWalker):
    def __init__(self, playlist):
        num = 1
        contents = []
        for t in playlist.tracks:
            contents.append(TrackItem(t, num))
            num += 1

        urwid.SimpleListWalker.__init__(self, contents)

    def set_focus(self, position):
        if not self:
            return

        # Highligt current track when focus leaves TracksView
        self[self.focus].set_attr('tr-normal')
        urwid.SimpleListWalker.set_focus(self, position)
        self[self.focus].set_attr('tr-selected')

class TracksView(urwid.Frame):
    def __init__(self, playlist, session):
        self.playlist = playlist
        self.session = session

        header = urwid.AttrWrap(TrackItem.create_columns('#', 'Title', 'Artist',
                'Album', 'Len.'), 'tr-header')
        footer = urwid.AttrWrap(urwid.Text('"%s" by %s, %d tracks' %
                (playlist.name, playlist.author, len(playlist.tracks)),
                align = 'center', wrap = 'clip'), 'tr-footer')
        tracks = urwid.ListBox(TrackWalker(playlist))
        self.__super.__init__(tracks, header = header, footer = footer)
        tracks.set_focus(0)

    def keypress(self, (maxcol, maxrow), key):
        key =  self.get_body().keypress((maxcol, maxrow-2), key)
        if key == 'enter':
            item,pos = self.get_body().get_focus()
            if item:
                self.session.play(self.playlist, item.track)
        else:
            return key

################################################################################
# Playlist view
class PlaylistItem(urwid.AttrWrap):
    def __init__(self, playlist, session):
        self.playlist = playlist
        widget = urwid.Text(playlist.name, wrap = 'clip')
        self.__super.__init__(widget, None, 'pl-focus')

        self.tracks_view = TracksView(playlist, session)

    def selectable(self):
        return True

    def keypress(self, (maxcol,), key):
        return key

class PlaylistWalker(urwid.SimpleListWalker):
    def __init__(self, session, tracks_container):
        self.tracks_container = tracks_container

        contents = []
        for p in session.playlists:
            contents.append(PlaylistItem(p, session))

        urwid.SimpleListWalker.__init__(self, contents)

    def set_focus(self, position):
        if not self:
            return

        # Highligt current playlist when focus leaves PlaylistsView
        self[self.focus].set_attr('pl-normal')
        urwid.SimpleListWalker.set_focus(self, position)
        self[self.focus].set_attr('pl-selected')

        # Display TracksView
        self.tracks_container.set_w(self[self.focus].tracks_view)

class PlaylistsView(urwid.ListBox):
    def __init__(self, session, tracks_container):
        self.playlists = PlaylistWalker(session, tracks_container)
        self.__super.__init__(self.playlists)
        self.set_focus(0)

################################################################################
# Browse view
class BrowseView(urwid.Columns):
    def __init__(self, session):
        dummy = urwid.Filler(urwid.Text(
            'No playlists found. Press "escape" to quit.', align = 'center'))
        tracks_container = urwid.WidgetWrap(dummy)
        playlists = PlaylistsView(session, tracks_container)
        self.__super.__init__([('fixed', 15, playlists), tracks_container], 1, 0)

################################################################################
# Player view
class PlayerView(urwid.Pile):
    def __init__(self, session):
        self.session = session
        self.status = urwid.Text('Stopped')
        self.__super.__init__([urwid.Divider('─'), self.status])

    def selectable(self):
        return False

################################################################################
# Root view
class RootView(urwid.Frame):
    def __init__(self, session):
        header = urwid.AttrWrap(urwid.Text('♪ Cambodia ♪',
                align = 'center', wrap = 'clip'), 'header')
        player = PlayerView(session)
        browser = BrowseView(session)
        self.__super.__init__(browser, header = header, footer = player)

################################################################################
# Spotify session
class SpotifySession(spytify.Spytify):
    def __init__(self, username, password):
        self.username = username
        self.logged_in = False
        self.started = False
        self.playing = False

        print 'Connecting...'
        self.session = spytify.Spytify(username, password)

        self.logged_in = True

        print 'Loading playlists...'
        self.playlists = self.session.stored_playlists
        if not self.playlists:
            self.playlists = []

        #print 'Searching...'
        #testlist = self.session.search('album:"SimCity 3000"')
        #if testlist:
        #    self.playlists.insert(0, testlist)

    def __del__(self):
        if self.logged_in:
            print 'Disconnecting...'
            self.session.close()

    def toggle_playback(self):
        if self.playing:
            self.session.pause()
            playing = False
        elif self.started:
            self.session.resume()
            playing = True

    def play(self, playlist, track):
        self.session.play_list(playlist, track)
        self.started = True
        self.playing = True

    def stop(self):
        self.started = False
        self.playing = False

################################################################################
# Manager
class Manager:
    def main(self, username, password):
        try:
            self.session = SpotifySession(username, password)

            print 'All good, running GUI...'
            self.view = RootView(self.session)

            self.ui = urwid.curses_display.Screen()
            self.ui.register_palette([
                ('header',      'white',    'black',       'bold'),
                # Playlist
                ('pl-normal',   'default',  'default'),
                ('pl-focus',    'black',    'light gray',  'standout'),
                ('pl-selected', 'white',    'black',       'bold'),
                # Tracks
                ('tr-header',   'dark gray', 'default',    'bold'),
                ('tr-footer',   'dark gray', 'default'),
                ('tr-normal',   'default',   'default'),
                ('tr-focus',    'black',     'light gray', 'standout'),
                ('tr-selected', 'white',     'black',      'bold'),
                ('tr-na',       'dark red',  'default'),
                ])
            self.ui.run_wrapper(self.run)

        except spytify.SpytifyError:
            print >>sys.stderr, 'Ouch, Spotify error: "', sys.exc_value, '"'
            return 1

        return 0

    def run(self):
        self.size = self.ui.get_cols_rows()

        self.done = False
        while not self.done:
            canvas = self.view.render(self.size, focus=True)
            self.ui.draw_screen(self.size, canvas)
            while True:
                keys = self.ui.get_input()
                if keys:
                    self.handle_input(keys)
                    break;

    def handle_input(self, keys):
        for k in keys:
            if k == 'esc':
                self.done = True
            elif k == 'window resize':
                self.size = self.ui.get_cols_rows()
            else:
                k = self.view.keypress(self.size, k)

                # FIXME: These doesn't actually work.
                if k == 'space':
                    self.session.toggle_playback()
                elif k == 'backspace':
                    self.session.stop()

if __name__ == '__main__':
    username = raw_input("Enter your username: ").strip()

    if not username:
        print >>sys.stderr, "Empty username, exiting."
        sys.exit(1)

    password = getpass("Enter your password: ").strip()
    if not password:
        print >>sys.stderr, "Empty password, exiting."
        sys.exit(1)

    sys.exit(Manager().main(username, password))
