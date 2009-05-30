/*
 * A very simple despotify client, to show how the library is used.
 *
 * $Id$
 *
 */

#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <wchar.h>
#include "despotify.h"

/* these are global to allow the callback to access them */
static struct playlist* lastlist = NULL;
static int listoffset = 0;

struct playlist* get_playlist(struct playlist* rootlist, int num)
{
    struct playlist* p = rootlist;

    if (!p) {
        wprintf(L"Stored lists not loaded. Run 'list' without parameter to load.\n");
    }
    else {
        /* skip to playlist number <num> */
        for (int i = 1; i < num && p; i++)
            p = p->next;


        if (!p)
            wprintf(L"Invalid playlist number %d\n", num);
    }

    return p;
}

void print_list_of_lists(struct playlist* rootlist)
{
    if (!rootlist) {
        wprintf(L" <no stored playlists>\n");
    }
    else {
        int count=1;
        for (struct playlist* p = rootlist; p; p = p->next)
            wprintf(L"%2d: %-40s %3d %c %s\n", count++, p->name, p->num_tracks,
                   p->is_collaborative ? '*' : ' ', p->author);
    }
}

void print_tracks(struct track* head)
{
    if (!head) {
        wprintf(L" <empty playlist>\n");
        return;
    }

    int count = 1;
    for (struct track* t = head; t; t = t->next) {
        if (t->has_meta_data) {
            wprintf(L"%3d: %-40s %2d:%02d ", count++, t->title,
                   t->length / 60000, t->length % 60000 / 1000);
            for (struct artist* a = t->artist; a; a = a->next)
                wprintf(L"%s%s", a->name, a->next ? ", " : "");
            wprintf(L" %s\n", t->playable ? "" : "(Unplayable)");
        }
        else
            wprintf(L"%3d: N/A\n", count++);
    }
}

void print_track_full(struct track* t)
{
    if(t->has_meta_data) {
        wprintf(L"\nTitle: %s\nAlbum: %s\nArtist(s): ",
               t->title, t->album);

        for (struct artist* a = t->artist; a; a = a->next)
            wprintf(L"%s%s", a->name, a->next ? ", " : "");

        wprintf(L"\nYear: %d\nLength: %02d:%02d\n\n",
               t->year, t->length / 60000, t->length % 60000 / 1000);
    } else {
        wprintf(L" <track has no metadata>\n");
    }
}

void print_album(struct album_browse* a)
{
    wprintf(L"\nName: %s\nYear: %d\n",
            a->name, a->year);
    print_tracks(a->tracks);
}

void print_artist(struct artist_browse* a)
{
    wprintf(L"\nName: %s\n"
           "Genres: %s\n"
           "Years active: %s\n"
           "%d albums:\n",
           a->name, a->genres, a->years_active, a->num_albums);
    for (struct album_browse* al = a->albums; al; al = al->next)
        wprintf(L" %s (%d)\n", al->name, al->year);
}

void print_playlist(struct playlist* pls)
{
    wprintf(L"\nName: %s\nAuthor: %s\n",
           pls->name, pls->author);
    print_tracks(pls->tracks);
}

void print_search(struct search_result *search)
{
    if (search->suggestion[0])
        wprintf(L"\nDid you mean \"%s\"?\n", search->suggestion);

    if (search->total_artists > 0) {
        wprintf(L"\nArtists found (%d):\n", search->total_artists);

        for (struct artist* artist = search->artists; artist; artist = artist->next)
            wprintf(L" %s\n", artist->name);
    }

    if (search->total_albums > 0) {
        wprintf(L"\nAlbums found (%d):\n", search->total_albums);
        for (struct album* album = search->albums; album; album = album->next)
            wprintf(L" %s\n", album->name);
    }

    if (search->total_tracks > 0) {
        wprintf(L"\nTracks found (%d/%d):\n", search->playlist->num_tracks, search->total_tracks);
        print_tracks(search->tracks);
    }
}

void print_info(struct despotify_session* ds)
{
    struct user_info* user = ds->user_info;
    wprintf(L"Username       : %s\n", user->username);
    wprintf(L"Country        : %s\n", user->country);
    wprintf(L"Account type   : %s\n", user->type);
    wprintf(L"Account expiry : %s", ctime(&user->expiry));
    wprintf(L"Host           : %s:%d\n", user->server_host, user->server_port);
    wprintf(L"Last ping      : %s", ctime(&user->last_ping));

    if (strncmp(user->type, "premium", 7)) {
        wprintf(L"\n=================================================\n"
               "                  N O T I C E\n"
               "       You do not have a premium account.\n"
               "     Spotify services will not be available.\n"
               "=================================================\n");
    }
}

void print_help(void)
{
    wprintf(L"\nAvailable commands:\n\n"
           "list [num]              List stored playlists\n"
           "rename [num] [string]   Rename playlist\n"
           "collab [num]            Toggle playlist collaboration\n"
           "\n"
           "search [string]         Search for [string] or get next 100 results\n"
           "artist [num]            Show information about artist for track [num]\n"
           "album [num]             List album for track [num]\n"
           "uri [string]            Display info about Spotify URI\n"
           "portrait [num]          Save artist portrait to portrait.jpg\n"
           "\n"
           "play [num]              Play track [num] in the last viewed list\n"
           "playalbum [num]         Play album for track [num]\n"
           "stop, pause, resume     Control playback\n"
           "\n"
           "info                    Details about your account and current connection\n"
           "help                    This text\n"
           "quit                    Quit\n");
}

void command_loop(struct despotify_session* ds)
{
    bool loop = true;
    char buf[80];
    struct playlist* rootlist = NULL;
    struct playlist* searchlist = NULL;
    struct search_result *search = NULL;
    struct album_browse* playalbum = NULL;

    print_help();

    do {
        wprintf(L"\n> ");
        fflush(stdout);
        bzero(buf, sizeof buf);
        fgets(buf, sizeof buf -1, stdin);
        buf[strlen(buf) - 1] = 0; /* remove newline */

        /* list */
        if (!strncmp(buf, "list", 4)) {
            int num = atoi(buf + 5);
            if (num) {
                struct playlist* p = get_playlist(rootlist, num);

                if (p) {
                    print_tracks(p->tracks);
                    lastlist = p;
                }
            }
            else {
                if (!rootlist)
                    rootlist = despotify_get_stored_playlists(ds);
                print_list_of_lists(rootlist);
            }
        }

        /* rename */
        else if (!strncmp(buf, "rename", 6)) {
            int num = 0;
            char *name = 0;
            if (strlen(buf) > 9) {
                num = atoi(buf + 7);
                name = strchr(buf + 7, ' ') + 1;
            }

            if (num && name && name[0]) {
                struct playlist* p = get_playlist(rootlist, num);

                if (p) {
                    if (despotify_rename_playlist(ds, p, name))
                        wprintf(L"Renamed playlist %d to \"%s\".\n", num, name);
                    else
                        wprintf(L"Rename failed: %s\n", despotify_get_error(ds));
                }
            }
            else
                wprintf(L"Usage: rename [num] [string]\n");
        }

        /* collab */
        else if (!strncmp(buf, "collab", 6)) {
            int num = 0;
            if (strlen(buf) > 7)
                num = atoi(buf + 7);

            if (num) {
                struct playlist* p = get_playlist(rootlist, num);

                if (p) {
                    if (despotify_set_playlist_collaboration(ds, p, !p->is_collaborative))
                        wprintf(L"Changed playlist %d collaboration to %s.\n",
                                num, p->is_collaborative ? "ON" : "OFF");
                    else
                        wprintf(L"Setting playlist collaboration state failed: %s\n",
                                despotify_get_error(ds));
                }
            }
            else
                wprintf(L"Usage: collab [num]\n");
        }

        /* search */
        else if (!strncmp(buf, "search", 6)) {
            if (buf[7]) {
                if (search)
                    despotify_free_search(search);

                despotify_stop(ds); /* since we replace the list */
                search = despotify_search(ds, buf + 7, MAX_SEARCH_RESULTS);
                if (!search) {
                    wprintf(L"Search failed: %s\n", despotify_get_error(ds));
                    continue;
                }
                searchlist = search->playlist;
            }
            else if (searchlist && (searchlist->num_tracks < search->total_tracks))
                if (!despotify_search_more(ds, search, searchlist->num_tracks, MAX_SEARCH_RESULTS)) {
                    wprintf(L"Search failed: %s\n", despotify_get_error(ds));
                    continue;
                }

            if (searchlist) {
                print_search(search);


                lastlist = searchlist;
            }
            else
                wprintf(L"No previous search\n");
        }

        /* artist */
        else if (!strncmp(buf, "artist", 6)) {
            int num = atoi(buf + 7);
            if (!num) {
                wprintf(L"usage: artist [num]\n");
                continue;
            }
            if (!lastlist) {
                wprintf(L"No playlist\n");
                continue;
            }

            /* find the requested track */
            struct track* t = lastlist->tracks;
            for (int i=1; i<num; i++)
                t = t->next;

            for (struct artist* aptr = t->artist; aptr; aptr = aptr->next) {
                struct artist_browse* a = despotify_get_artist(ds, aptr->id);
                print_artist(a);
                despotify_free_artist_browse(a);
            }
        }

        /* album */
        else if (!strncmp(buf, "album", 5)) {
            int num = atoi(buf + 6);
            if (!num) {
                wprintf(L"usage: album [num]\n");
                continue;
            }
            if (!lastlist) {
                wprintf(L"No playlist\n");
                continue;
            }

            /* find the requested track */
            struct track* t = lastlist->tracks;
            for (int i=1; i<num; i++)
                t = t->next;

            if (t) {
                struct album_browse* a = despotify_get_album(ds, t->album_id);
                if (a) {
                    print_album(a);
                    despotify_free_album_browse(a);
                }
                else
                    wprintf(L"Got no album for id %s\n", t->album_id);
            }
        }

        /* playalbum */
        else if (!strncmp(buf, "playalbum", 9)) {
            int num = atoi(buf + 10);
            if (!num) {
                wprintf(L"usage: playalbum [num]\n");
                continue;
            }
            if (!lastlist) {
                wprintf(L"No playlist\n");
                continue;
            }

            /* find the requested track */
            struct track* t = lastlist->tracks;
            for (int i=1; i<num; i++)
                t = t->next;


            if (t) {
                if (playalbum)
                    despotify_free_album_browse(playalbum);

                despotify_stop(ds);
                playalbum = despotify_get_album(ds, t->album_id);

                if (playalbum)
                    despotify_play(ds, playalbum->tracks, true);
                else
                    wprintf(L"Got no album for id %s\n", t->album_id);
            }
        }

        /* uri */
        else if (!strncmp(buf, "uri", 3)) {
            char *uri = buf + 4;
            if(strlen(uri) == 0) {
                wprintf(L"usage: info <uri>\n");
                continue;
            }

            struct link* link = despotify_link_from_uri(uri);
            struct album_browse* al;
            struct artist_browse* ar;
            struct playlist* pls;
            struct search_result* s;
            struct track* t;

            switch(link->type) {
                case LINK_TYPE_ALBUM:
                    al = despotify_link_get_album(ds, link);
                    if(al) {
                        print_album(al);
                        despotify_free_album_browse(al);
                    }
                    break;

                case LINK_TYPE_ARTIST:
                    ar = despotify_link_get_artist(ds, link);
                    if(ar) {
                        print_artist(ar);
                        despotify_free_artist_browse(ar);
                    }
                    break;

                case LINK_TYPE_PLAYLIST:
                    pls = despotify_link_get_playlist(ds, link);
                    if(pls) {
                        print_playlist(pls);
                        despotify_free_playlist(pls);
                    }
                    break;

                case LINK_TYPE_SEARCH:
                    s = despotify_link_get_search(ds, link);
                    if(s) {
                        print_search(s);
                        despotify_free_search(s);
                    }
                    break;

                case LINK_TYPE_TRACK:
                    t = despotify_link_get_track(ds, link);
                    if(t) {
                        print_track_full(t);
                        despotify_free_track(t);
                    }
                    break;

                default:
                    wprintf(L"%s is a invalid Spotify URI\n", uri);
            }

            despotify_free_link(link);
        }

        /* portrait */
        else if (!strncmp(buf, "portrait", 8)) {
            int num = atoi(buf + 9);
            if (!num) {
                wprintf(L"usage: portrait [num]\n");
                continue;
            }
            if (!lastlist) {
                wprintf(L"No playlist\n");
                continue;
            }

            /* find the requested artist */
            struct track* t = lastlist->tracks;
            for (int i=1; i<num; i++)
                t = t->next;
            struct artist_browse* a = despotify_get_artist(ds, t->artist->id);
            if (a && a->portrait_id[0]) {
                int len;
                void* portrait = despotify_get_image(ds, a->portrait_id, &len);
                if (portrait && len) {
                    wprintf(L"Writing %d bytes into portrait.jpg\n", len);
                    FILE* f = fopen("portrait.jpg", "w");
                    if (f) {
                        fwrite(portrait, len, 1, f);
                        fclose(f);
                    }
                    free(portrait);
                }
            }
            else
                wprintf(L"Artist %s has no portrait.\n", a->name);
            despotify_free_artist_browse(a);
        }

        /* play */
        else if (!strncmp(buf, "play", 4)) {
            if (!lastlist) {
                wprintf(L"No list to play from. Use 'list' or 'search' to select a list.\n");
                continue;
            }

            /* skip to track <num> */
            listoffset = atoi(buf + 5);
            struct track* t = lastlist->tracks;
            for (int i=1; i<listoffset && t; i++)
                t = t->next;
            if (t)
                despotify_play(ds, t, true);
            else
                wprintf(L"Invalid track number %d\n", listoffset);
        }

        /* stop */
        else if (!strncmp(buf, "stop", 4)) {
            despotify_stop(ds);
        }

        /* pause */
        else if (!strncmp(buf, "pause", 5)) {
            despotify_pause(ds);
        }

        /* resume */
        else if (!strncmp(buf, "resume", 5)) {
            despotify_resume(ds);
        }

        /* info */
        else if (!strncmp(buf, "info", 4)) {
            print_info(ds);
        }

        /* help */
        else if (!strncmp(buf, "help", 4)) {
            print_help();
        }

        /* quit */
        else if (!strncmp(buf, "quit", 4)) {
            loop = false;
        }
    } while(loop);

    if (rootlist)
        despotify_free_playlist(rootlist);

    if (search)
        despotify_free_search(search);

    if (playalbum)
        despotify_free_album_browse(playalbum);
}

void callback(int signal, void* data)
{
    (void)data;

    switch (signal) {
        case DESPOTIFY_TRACK_CHANGE:
            listoffset++;
            struct track* t = lastlist->tracks;
            for (int i=1; i<listoffset && t; i++)
                t = t->next;
            if (t)
                wprintf(L"New track: %d: %s / %s (%d:%02d)\n",
                        listoffset, t->title, t->artist->name,
                        t->length / 60000, t->length % 60000 / 1000);
            break;
    }
}

int main(int argc, char** argv)
{
    setlocale(LC_ALL, "");

    if (argc < 3) {
        wprintf(L"Usage: %s <username> <password>\n", argv[0]);
        return 1;
    }

    if (!despotify_init())
    {
        wprintf(L"despotify_init() failed\n");
        return 1;
    }

    struct despotify_session* ds = despotify_init_client(callback);
    if (!ds) {
        wprintf(L"despotify_init_client() failed\n");
        return 1;
    }

    if (!despotify_authenticate(ds, argv[1], argv[2])) {
        printf( "Authentication failed: %s\n", despotify_get_error(ds));
        despotify_exit(ds);
        return 1;
    }

    print_info(ds);

    command_loop(ds);

    despotify_exit(ds);

    if (!despotify_cleanup())
    {
        wprintf(L"despotify_cleanup() failed\n");
        return 1;
    }

    return 0;
}
