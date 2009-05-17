from despotify cimport *

cdef class SessionStruct
cdef class Album(SessionStruct)
cdef class Artist(SessionStruct)
cdef class SearchResult(SessionStruct)
cdef class Playlist(SessionStruct)
cdef class RootList(SessionStruct)
cdef class Track(SessionStruct)

cdef class SessionStruct:
    cdef despotify_session* ds
    cdef Album create_album(self, album* album, bint take_owner=?)
    cdef Album create_album_full(self, album_browse* album, bint take_owner=?)

    cdef Artist create_artist(self, artist* artist, bint take_owner=?)
    cdef Artist create_artist_full(self, artist_browse* artist, bint take_owner=?)

    cdef Playlist create_playlist(self, playlist* playlist, bint take_owner=?)
    cdef RootList create_rootlist(self)

    cdef SearchResult create_search_result(self, search_result* result, bint take_owner=?)
    cdef Track create_track(self, track* track)

    cdef list albums_to_list(self, album_browse* albums)
    cdef list artists_to_list(self, artist* artists)
    cdef list playlists_to_list(self, playlist* playlists)
    cdef list tracks_to_list(self, track* tracks)

cdef class Spytify(SessionStruct):
    cdef RootList _stored_playlists

cdef class AlbumData:
    cdef album* data
    cdef char* name(self)
    cdef char* id(self)
    cdef char* artist(self)
    cdef char* artist_id(self)
    cdef char* cover_id(self)
    cdef float popularity(self)
    cdef AlbumData next(self)

cdef class AlbumDataFull(AlbumData):
    cdef album_browse* browse
    cdef int num_tracks(self)
    cdef track* tracks(self)
    cdef int year(self)
    cdef AlbumDataFull next_full(self)

cdef class Album(SessionStruct):
    cdef AlbumData data
    cdef AlbumDataFull full_data
    cdef bint take_owner

    cdef get_full_data(self)

cdef class ArtistData:
    cdef artist* data
    cdef char* name(self)
    cdef char* id(self)
    cdef char* portrait_id(self)
    cdef float popularity(self)
    cdef ArtistData next(self)

cdef class ArtistDataFull(ArtistData):
    cdef artist_browse* browse
    cdef char* text(self)
    cdef char* genres(self)
    cdef char* years_active(self)
    cdef int num_albums(self)
    cdef album_browse* albums(self)

cdef class Artist(SessionStruct):
    cdef ArtistData data
    cdef ArtistDataFull full_data
    cdef bint take_owner

    cdef get_full_data(self)

cdef class SearchResult(SessionStruct):
    cdef search_result* data
    cdef Playlist playlist
    cdef bint take_owner

cdef class SearchTracks(SessionStruct):
    cdef SearchResult result

cdef class SearchIterator(SessionStruct):
    cdef SearchTracks parent
    cdef int i

cdef class Playlist(SessionStruct):
    cdef playlist* data
    cdef bint take_owner

cdef class RootList(SessionStruct):
    cdef fetch(self)
    cdef playlist* data 
    cdef list playlists

cdef class RootIterator:
    cdef RootList parent
    cdef int i

cdef class Track(SessionStruct):
    cdef track* data
