# vim: set fileencoding=utf-8 filetype=pyrex :

cdef class SearchResult:
    def __init__(self):
        raise TypeError("This class cannot be instantiated from Python")

    property query:
        def __get__(self):
            return <char*>self.data.query

    property suggestion:
        def __get__(self):
            if self.data.suggestion:
                return <char*>self.data.suggestion
            else:
                return None

    property total_artists:
        def __get__(self):
            return self.data.total_artists

    property total_albums:
        def __get__(self):
            return self.data.total_albums

    property total_tracks:
        def __get__(self):
            return self.data.total_tracks

    property playlist:
        def __get__(self):
            return self.playlist

    def __dealloc__(self):
        if self.take_owner:
            despotify_free_search(self.data)

cdef class SearchTracks:
    def __init__(self, SearchResult result):
        self.result = result
        self.has_tracks = sum(len, result.lists)
    
    def __getitem__(self, item):
        cdef int start, end, i
        cdef Playlist more, pl
        cdef list items 

        if isinstance(item, int):
            while item >= self.has_tracks:
                more = self.result.fetch_more()
                if not more:
                    raise IndexError('search result index out of range')

                self.has_tracks += len(more)

            pl = self.result.playlists[-1]
            i = self.has_tracks - len(pl) 
            return pl.tracks[item - i]
        else:
            i = item.start
            items = []
            while i < item.stop:
                items.append(self[i])
                i += item.step

            return items


cdef class SearchIterator:
    def __init__(self, SearchTracks parent):
        self.parent = parent
        self.i = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.i >= len(self.parent):
            raise StopIteration()

        retval = self.parent[self.i]
        self.i = self.i + 1
        return retval
