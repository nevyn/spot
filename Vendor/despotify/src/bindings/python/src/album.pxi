# vim: set fileencoding=utf-8 filetype=pyrex :

cdef class AlbumData:
    def __init__(self):
        self.data = NULL

    cdef char* name(self):
        return self.data.name if self.data != NULL else NULL
    cdef char* id(self):
        return self.data.id if self.data != NULL else NULL
    cdef char* artist(self):
        return self.data.artist if self.data != NULL else NULL
    cdef char* artist_id(self):
        return self.data.artist_id if self.data != NULL else NULL
    cdef char* cover_id(self):
        return self.data.cover_id if self.data != NULL else NULL
    cdef float popularity(self):
        return self.data.popularity if self.data != NULL else 0.0

    cdef AlbumData next(self):
        if self.data == NULL:
            return None
        cdef AlbumData next = AlbumData()
        next.data = self.data.next
        return next

cdef class AlbumDataFull(AlbumData):
    def __init__(self):
        self.browse = NULL

    # Overwriting the ones in AlbumData.
    cdef char* name(self):
        return self.browse.name if self.browse != NULL else NULL
    cdef char* id(self):
        return self.browse.id if self.browse != NULL else NULL
    cdef char* cover_id(self):
        return self.browse.cover_id if self.browse != NULL else NULL
    cdef float popularity(self):
        return self.browse.popularity if self.browse != NULL else 0.0

    # New ones in Full
    cdef int num_tracks(self):
        return self.browse.num_tracks if self.browse != NULL else 0
    cdef track* tracks(self):
        return self.browse.tracks if self.browse != NULL else NULL
    cdef int year(self):
        return self.browse.year if self.browse != NULL else 0

    cdef AlbumDataFull next_full(self):
        if self.browse == NULL:
            return None

        cdef AlbumDataFull next = AlbumDataFull()
        next.browse = self.browse.next
        return next

cdef class Album(SessionStruct):
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")

    cdef get_full_data(self):
        if self.full_data == None:
            self.full_data = AlbumDataFull()
            self.full_data.browse = despotify_get_album(self.ds, self.data.id())
            self.data = self.full_data

    property name:
        def __get__(self):
            return self.data.name()

    property id:
        def __get__(self):
            return self.data.id()

    property tracks:
        def __get__(self):
            self.get_full_data()
            return self.tracks_to_list(self.full_data.tracks())

    property year:
        def __get__(self):
            self.get_full_data()
            return self.full_data.year()

    property cover_id:
        def __get__(self):
            return self.data.cover_id()

    property popularity:
        def __get__(self):
            return self.data.popularity()

    def __dealloc__(self):
        if self.take_owner:
            if self.full_data is not None:
                if self.full_data.browse != NULL:
                    despotify_free_album_browse(self.full_data.browse)

    def __repr__(self):
        return '<Album: %s (%s)>' % (self.name, self.id)
