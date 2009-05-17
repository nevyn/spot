# vim: set fileencoding=utf-8 filetype=pyrex :

cdef class ArtistData:
    def __init__(self):
        self.data = NULL

    cdef char* name(self):
        return self.data.name if self.data != NULL else NULL

    cdef char* id(self):
        return self.data.id if self.data != NULL else NULL

    cdef char* portrait_id(self):
        return self.data.portrait_id if self.data != NULL else NULL

    cdef float popularity(self):
        return self.data.popularity if self.data != NULL else 0.0

    cdef ArtistData next(self):
        if self.data == NULL:
            return None

        cdef ArtistData next = ArtistData()
        next.data = self.data.next
        return next
    
cdef class ArtistDataFull(ArtistData):
    def __init__(self):
        self.browse = NULL

    # Old ones from ArtistData, using self.browse.
    cdef char* name(self):
        return self.browse.name if self.browse != NULL else NULL
    cdef char* id(self):
        return self.browse.id if self.browse != NULL else NULL
    cdef char* portrait_id(self):
        return self.browse.portrait_id if self.browse != NULL else NULL
    cdef float popularity(self):
        return self.browse.popularity if self.browse != NULL else 0.0

    # New ones.
    cdef char* text(self):
        return self.browse.text if self.browse != NULL else NULL
    cdef char* genres(self):
        return self.browse.genres if self.browse != NULL else NULL
    cdef char* years_active(self):
        return self.browse.years_active if self.browse != NULL else NULL
    cdef int num_albums(self):
        return self.browse.num_albums if self.browse != NULL else 0
    cdef album_browse* albums(self):
        return self.browse.albums if self.browse != NULL else NULL


cdef class Artist:
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")

    cdef get_full_data(self):
        if self.full_data == None:
            self.full_data = AlbumDataFull()
            self.full_data.browse = despotify_get_artist(self.ds, self.data.id())
            self.data = self.full_data

    property name:
        def __get__(self):
            return self.data.name()

    property id:
        def __get__(self):
            return self.data.id()

    property text:
        def __get__(self):
            self.get_full_data()
            return self.full_data.text()

    property portrait_id:
        def __get__(self):
            return self.data.portrait_id()

    property genres:
        def __get__(self):
            self.get_full_data()
            return self.full_data.genres()

    property popularity:
        def __get__(self):
            return self.data.popularity()

    property albums:
        def __get__(self):
            self.get_full_data()
            return self.albums_to_list(self.full_data.albums())

    def __dealloc__(self):
        if self.take_owner:
            if self.full_data is not None:
                if self.full_data.browse != NULL:
                    despotify_free_artist_browse(self.full_data.browse)


    def __repr__(self):
        return '<Artist: %s (%s)>' % (self.name, self.id)

