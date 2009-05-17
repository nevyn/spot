cdef extern from "despotify.h":
    int MAX_SEARCH_RESULTS

    cdef enum link_type:
        LINK_TYPE_INVALID = 0
        LINK_TYPE_ALBUM = 1
        LINK_TYPE_ARTIST = 2
        LINK_TYPE_PLAYLIST = 3
        LINK_TYPE_SEARCH = 4
        LINK_TYPE_TRACK = 5

    cdef struct album:
        char * name
        char * id
        char * artist
        char * artist_id
        char * cover_id
        float popularity
        album * next

    cdef struct artist:
        char * name
        char * id
        char * portrait_id
        float popularity
        artist * next

    cdef struct track:
        bint has_meta_data
        bint playable
        unsigned char * track_id
        unsigned char * file_id
        unsigned char * album_id
        unsigned char * cover_id
        unsigned char * key
        char * title
        artist * artist
        char * album
        int length
        int tracknumber
        int year
        float popularity
        track * next

    cdef struct album_browse:
        char * name
        char * id
        int num_tracks
        track * tracks
        int year
        char * cover_id
        float popularity
        album_browse * next

    cdef struct artist_browse:
        char * name
        char * id
        char * text
        char * portrait_id
        char * genres
        char * years_active
        float popularity
        int num_albums
        album_browse * albums

    cdef struct link:
        char * uri
        char * arg
        link_type type

    cdef struct session:
        pass

    ctypedef long int time_t

    cdef struct user_info:
        char * username
        char * country
        char * type
        time_t expiry
        char * server_host
        short int server_port
        time_t last_ping

    cdef struct snd_session:
        pass

    cdef struct playlist:
        char * name
        char * author
        unsigned char * playlist_id
        bint is_collaborative
        int num_tracks
        unsigned int revision
        unsigned int checksum
        track * tracks
        playlist * next

    cdef struct search_result:
        unsigned char * query
        unsigned char * suggestion
        int total_artists
        int total_albums
        int total_tracks
        artist * artists
        album * albums
        track * tracks
        playlist * playlist

    cdef struct despotify_session:
        bint initialized
        session * session
        user_info * user_info
        snd_session * snd_session
        char * last_error
        album_browse * album_browse
        artist_browse * artist_browse
        track * track
        playlist * playlist
        int offset
        bint list_of_lists
        bint play_as_list

    bint despotify_init()
    char * despotify_get_error(despotify_session *)
    bint despotify_cleanup()

    despotify_session * despotify_init_client()
    bint despotify_authenticate(despotify_session *, char *, char *)
    void despotify_exit(despotify_session *)
    void despotify_free(despotify_session *, bint)

    void * despotify_get_image(despotify_session *, char *, int *)

    playlist * despotify_get_playlist(despotify_session *, char *)
    bint despotify_rename_playlist(despotify_session *, playlist *, char *)
    void despotify_free_playlist(playlist *)
    bint despotify_set_playlist_collaboration(despotify_session *, playlist *, bint)
    playlist * despotify_get_stored_playlists(despotify_session *)

    album_browse * despotify_get_album(despotify_session *, char *)
    void despotify_free_album_browse(album_browse *)

    artist_browse * despotify_get_artist(despotify_session *, char *)
    void despotify_free_artist_browse(artist_browse *)

    search_result * despotify_search(despotify_session *, char *, int)
    search_result * despotify_search_more(despotify_session *, search_result *, int, int)
    void despotify_free_search(search_result *)

    track * despotify_get_track(despotify_session *, char *)
    track * despotify_get_current_track(despotify_session *)
    track * despotify_get_tracks(despotify_session *, char * *, int)
    void despotify_free_track(track *)

    link * despotify_link_from_uri(char *)
    artist_browse * despotify_link_get_artist(despotify_session *, link *)
    album_browse * despotify_link_get_album(despotify_session *, link *)
    playlist * despotify_link_get_playlist(despotify_session *, link *)
    search_result * despotify_link_get_search(despotify_session *, link *)
    track * despotify_link_get_track(despotify_session *, link *)
    void despotify_free_link(link *)

    void despotify_uri2id(char *, char *)
    void despotify_id2uri(char *, char *)
    char * despotify_artist_to_uri(artist_browse *, char *)
    char * despotify_album_to_uri(album_browse *, char *)
    char * despotify_playlist_to_uri(playlist *, char *)
    char * despotify_search_to_uri(search_result *, char *)
    char * despotify_track_to_uri(track *, char *)

    bint despotify_pause(despotify_session *)
    bint despotify_play(despotify_session *, track *, bint)
    bint despotify_stop(despotify_session *)
    bint despotify_resume(despotify_session *)
