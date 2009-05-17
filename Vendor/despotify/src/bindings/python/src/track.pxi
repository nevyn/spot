# vim: set fileencoding=utf-8 filetype=pyrex :

cdef class Track:
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")

    property track_id:
        def __get__(self):
            return <char*>self.data.track_id

    property file_id:
        def __get__(self):
            return <char*>self.data.file_id

    def has_meta_data(self):
        return bool(self.data.has_meta_data)

    def is_playable(self):
        return bool(self.data.playable)

    property title:
        def __get__(self):
            return self.data.title

    property artists:
        def __get__(self):
            return self.artists_to_list(self.data.artist)

    property album:
        def __get__(self):
            return self.data.album

    property length:
        def __get__(self):
            return self.data.length

    property tracknumber:
        def __get__(self):
            return self.data.tracknumber

    property year:
        def __get__(self):
            return self.data.year

    property popularity:
        def __get__(self):
            return self.data.popularity

    def __repr__(self):
        return '<Track: %s - %s - %s (%s)>' % (", ".join([a.name for a in self.artists]), self.title, self.album, self.track_id)
