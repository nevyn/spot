/*
 * $Id$
 *
 * Playlist related stuff
 *
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "despotify.h"
#include "ezxml.h"
#include "util.h"
#include "xml.h"

void xmlstrncpy(char* dest, int len, ezxml_t xml, ...)
{
    va_list ap;
    ezxml_t r;

    va_start(ap, xml);
    r = ezxml_vget(xml, ap);
    va_end(ap);

    if (r) {
        strncpy(dest, r->txt, len);
        dest[len-1] = 0;
    }
}

void xmlatoi(int* dest, ezxml_t xml, ...)
{
    va_list ap;
    ezxml_t r;

    va_start(ap, xml);
    r = ezxml_vget(xml, ap);
    va_end(ap);

    if (r) {
        *dest = atoi(r->txt);
    }
}

void xmlatof(float* dest, ezxml_t xml, ...)
{
    va_list ap;
    ezxml_t r;

    va_start(ap, xml);
    r = ezxml_vget(xml, ap);
    va_end(ap);

    if (r) {
        *dest = (float)atof(r->txt);
    }
}

void xml_parse_version(struct playlist* pl, ezxml_t xml, ...)
{
    va_list ap;
    ezxml_t r;

    va_start(ap, xml);
    r = ezxml_vget(xml, ap);
    va_end(ap);

    if (r) {
        char ver[64];
        strncpy(ver, r->txt, sizeof ver);
        ver[sizeof ver-1] = 0;
        int collab;
        if (sscanf(ver, "%u,%u,%u,%u", &pl->revision, &pl->num_tracks,
                    &pl->checksum, &collab) != 4) {
            DSFYDEBUG("!!! List version parsing failed (%s)\n", ver);
        }
        pl->is_collaborative = collab;
    }
}

struct playlist* xml_parse_playlist(struct playlist* pl,
                                    unsigned char* xml,
                                    int len,
                                    bool list_of_lists)
{
    ezxml_t top = ezxml_parse_str(xml, len);
    ezxml_t tmpx = ezxml_get(top, "next-change",0, "change", 0, "ops", 0,
                             "add", 0, "items", -1);
    char* items = NULL;
    if (tmpx)
        items = tmpx->txt;

    while (items && *items && isspace(*items))
        items++;

    if (list_of_lists) {
        /* create list of playlists */
        struct playlist* prev = NULL;
        struct playlist* p = pl;

        for (char* id = strtok(items, ",\n"); id; id = strtok(NULL, ",\n"))
        {
            if (prev) {
                p = calloc(1, sizeof(struct playlist));
                prev->next = p;
            }
            DSFYstrncpy(p->playlist_id, id, sizeof p->playlist_id);
            prev = p;
        }
    }
    else {
        /* create list of tracks */
        struct track* prev = NULL;
        struct track* root = NULL;
        struct track* t = NULL;

        int track_count = 0;
        for (char* id = strtok(items, ",\n"); id; id = strtok(NULL, ",\n"))
        {
            t = calloc(1, sizeof(struct track));
            if (prev)
                prev->next = t;
            else
                root = t;
            DSFYstrncpy(t->track_id, id, sizeof t->track_id);
            prev = t;
            track_count++;
        }
        pl->tracks = root;
        pl->num_tracks = track_count; // FIXME: <version> parsing overwrites track_count
    }

    xmlstrncpy(pl->author, sizeof pl->author, top,
               "next-change",0, "change", 0, "user", -1);
    xmlstrncpy(pl->name, sizeof pl->name, top,
               "next-change",0, "change", 0, "ops",0, "name", -1);
    xml_parse_version(pl, top, "next-change", 0, "version", -1);

    ezxml_free(top);
    return pl;
}

bool xml_parse_confirm(struct playlist* pl,
                       unsigned char* xml,
                       int len)
{
    ezxml_t top = ezxml_parse_str(xml, len);

    bool confirm = !strncmp(top->name, "confirm", 7);

    if (confirm) {
        xml_parse_version(pl, top, "version", -1);
    }

    ezxml_free(top);
    return confirm;
}

void xml_free_playlist(struct playlist* pl)
{
    void* next_list = pl;
    for (struct playlist* p = next_list; next_list; p = next_list) {
        xml_free_track(p->tracks);
        next_list = p->next;
        free(p);
    }
}

static int parse_tracks(ezxml_t xml, struct track* t, bool ordered)
{
    int track_count = 0;
    struct track* prev = NULL;
    struct track* root = t;

    for (ezxml_t track = ezxml_get(xml, "track",-1); track; track = track->next)
    {
        /* is this an ordered list? in that case we have to find the
           right track struct for every track id */
        if (ordered) {
            char tid[33];
            xmlstrncpy(tid, sizeof tid, track, "id", -1);
            struct track* tt;
            for (tt = root; tt; tt = tt->next)
                if (!tt->has_meta_data &&
                    !strncmp(tt->track_id, tid, sizeof tt->track_id))
                    break;
            /* if we didn't find the id, check if an old, redirected
               id is used */
            if (!tt) {
                char rid[33];
                for (ezxml_t re = ezxml_child(track, "redirect"); re; re = re->next) {
                    strncpy(rid, re->txt, sizeof rid);
                    for (tt = root; tt; tt = tt->next) {
                        /* update to new id */
                        /* FIXME: This invalidates the playlist checksum */
                        if (!tt->has_meta_data &&
                            !strncmp(tt->track_id, rid, sizeof tt->track_id)) {
                            memcpy (tt->track_id, tid, sizeof tt->track_id);
                            break;
                        }
                    }
                    if (tt)
                        break;
                }
                /* we've wasted enough cpu cycles on this track now */
                if (!tt) {
                    DSFYDEBUG("!!! error: track id not found: %s\n", tid);
                    continue;
                }
            }
            t = tt;
        }
        else
            if (!t) {
                t = calloc(1, sizeof(struct track));
                prev->next = t;
            }

        xmlstrncpy(t->title, sizeof t->title, track, "title", -1);
        xmlstrncpy(t->album, sizeof t->album, track, "album", -1);

        xmlstrncpy(t->track_id, sizeof t->track_id, track, "id", -1);
        xmlstrncpy(t->cover_id, sizeof t->cover_id, track, "cover", -1);
        xmlstrncpy(t->album_id, sizeof t->album_id, track, "album-id", -1);

        /* create list of artists */
        struct artist* preva = NULL;
        struct artist* artist = calloc(1, sizeof(struct artist));
        t->artist = artist;
        ezxml_t xid = ezxml_get(track, "artist-id", -1);
        for (ezxml_t xa = ezxml_get(track, "artist", -1); xa; xa = xa->next) {
            if (preva) {
                artist = calloc(1, sizeof(struct artist));
                preva->next = artist;
            }
            DSFYstrncpy(artist->name, xa->txt, sizeof artist->name);

            if (xid) {
                DSFYstrncpy(artist->id, xid->txt, sizeof artist->id);
                xid = xid->next;
            }
            preva = artist;
        }

        ezxml_t file = ezxml_get(track, "files",0, "file",-1);
        if (file) {
            char* id = (char*)ezxml_attr(file, "id");
            if (id) {
                DSFYstrncpy(t->file_id, id, sizeof t->file_id);
                t->playable = true;
            }
        }

        xmlatoi(&t->year, track, "year", -1);
        xmlatoi(&t->length, track, "length", -1);
        xmlatoi(&t->tracknumber, track, "track-number", -1);
        xmlatof(&t->popularity, track, "popularity", -1);
        t->has_meta_data = true;

        prev = t;
        t = t->next;
        track_count++;
    }

    return track_count;
}

void xml_free_track(struct track* head)
{
    void* next_track = head;
    for (struct track* t = next_track; next_track; t = next_track) {
        if (t->key)
            free(t->key);

        xml_free_artist(t->artist);

        next_track = t->next;
        free(t);
    }
}


static void parse_album(ezxml_t top, struct album* a) {
    xmlstrncpy(a->name, sizeof a->name, top, "name", -1);
    xmlstrncpy(a->id, sizeof a->id, top, "id", -1);
    xmlstrncpy(a->artist, sizeof a->artist, top, "artist-name", -1);
    xmlstrncpy(a->artist_id, sizeof a->artist_id, top, "artist-id", -1);
    xmlstrncpy(a->cover_id, sizeof a->cover_id, top, "cover", -1);
    xmlatof(&a->popularity, top, "popularity", -1);
}

static void parse_artist(ezxml_t top, struct artist *a) {
    xmlstrncpy(a->name, sizeof a->name, top, "name", -1);
    xmlstrncpy(a->id, sizeof a->id, top, "id", -1);
    xmlstrncpy(a->portrait_id, sizeof a->portrait_id, top,
               "portrait", 0, "id", -1);
    xmlatof(&a->popularity, top, "popularity", -1);
}

static void parse_browse_album(ezxml_t top, struct album_browse* a)
{
    xmlstrncpy(a->name, sizeof a->name, top, "name", -1);
    xmlstrncpy(a->id, sizeof a->id, top, "id", -1);
    xmlstrncpy(a->cover_id, sizeof a->cover_id, top, "cover", -1);
    xmlatoi(&a->year, top, "year", -1);
    xmlatof(&a->popularity, top, "popularity", -1);

    /* TODO: support multiple discs per album  */
    a->tracks = calloc(1, sizeof(struct track));
    ezxml_t disc = ezxml_get(top, "discs",0,"disc", -1);
    a->num_tracks = parse_tracks(disc, a->tracks, false);

    /* Copy missing metadata from album to tracks */
    int count = 0;
    for (struct track *t = a->tracks; t; t = t->next) {
        DSFYstrncpy(t->album, a->name, sizeof t->album);
        DSFYstrncpy(t->album_id, a->id, sizeof t->album_id);
        DSFYstrncpy(t->cover_id, a->cover_id, sizeof t->cover_id);
        t->year = a->year;
        count++;
    }
}


int xml_parse_tracklist(struct track* firsttrack,
                        unsigned char* xml,
                        int len,
                        bool ordered)
{
    ezxml_t top = ezxml_parse_str(xml, len);

    ezxml_t tracks = ezxml_get(top, "tracks",-1);
    int num_tracks = parse_tracks(tracks, firsttrack, ordered);
    ezxml_free(top);

    return num_tracks;
}


int xml_parse_search(struct search_result* search,
                     struct track* firsttrack,
                     unsigned char* xml, int len)
{
    ezxml_t top = ezxml_parse_str(xml, len);

    xmlstrncpy(search->suggestion, sizeof search->suggestion,
               top, "did-you-mean", -1);
    xmlatoi(&search->total_artists, top, "total-artists", -1);
    xmlatoi(&search->total_albums, top, "total-albums", -1);
    xmlatoi(&search->total_tracks, top, "total-tracks", -1);

    ezxml_t artists = ezxml_get(top, "artists",-1);
    struct artist *prev = NULL;
    struct artist *artist = calloc(1, sizeof(struct artist));
    search->artists = artist;
    for (ezxml_t xa = ezxml_get(artists, "artist", -1); xa; xa = xa->next) {
        if(prev) {
            artist = calloc(1, sizeof(struct artist));
            prev->next = artist;
        }

        parse_artist(xa, artist);
        prev = artist;
    }

    ezxml_t albums = ezxml_get(top, "albums",-1);
    struct album *aprev = NULL;
    struct album *album = calloc(1, sizeof(struct album));
    search->albums = album;
    for (ezxml_t xa = ezxml_get(albums, "album", -1); xa; xa = xa->next) {
        if(aprev) {
            album = calloc(1, sizeof(struct album));
            aprev->next = album;
        }

        parse_album(xa, album);
        aprev = album;
    }

    ezxml_t tracks = ezxml_get(top, "tracks",-1);
    int num_tracks = parse_tracks(tracks, firsttrack, false);

    ezxml_free(top);

    return num_tracks;
}


bool xml_parse_browse_artist(struct artist_browse* a,
                      unsigned char* xml,
                      int len )
{
    ezxml_t top = ezxml_parse_str(xml, len);

    xmlstrncpy(a->name, sizeof a->name, top, "name", -1);
    xmlstrncpy(a->genres, sizeof a->genres, top, "genres", -1);
    xmlstrncpy(a->years_active, sizeof a->years_active, top, "years-active",-1);
    xmlstrncpy(a->id, sizeof a->id, top, "id", -1);
    xmlstrncpy(a->portrait_id, sizeof a->portrait_id, top,
               "portrait", 0, "id", -1);
    xmlatof(&a->popularity, top, "popularity", -1);

    ezxml_t x = ezxml_get(top, "bios",0,"bio",0,"text",-1);
    if (x) {
        int len = strlen(x->txt);
        a->text = malloc(len + 1);
        memcpy(a->text, x->txt, len+1);
    }

    /* traverse albums */
    x = ezxml_get(top, "albums",-1);
    struct album_browse* prev = NULL;
    struct album_browse* album = calloc(1, sizeof(struct album_browse));
    a->albums = album;
    int album_count = 0;
    for (ezxml_t xalb = ezxml_get(x, "album", -1); xalb; xalb = xalb->next) {
        if (prev) {
            album = calloc(1, sizeof(struct album));
            prev->next = album;
        }

        parse_browse_album(xalb, album);

        prev = album;
        album_count++;
    }
    a->num_albums = album_count;
    ezxml_free(top);

    return true;
}

void xml_free_artist(struct artist *artist) {
    struct artist* next_artist = artist;
    for (struct artist* a = next_artist; next_artist; a = next_artist) {
        next_artist = a->next;
        free(a);
    }
}

void xml_free_artist_browse(struct artist_browse* artist)
{
    if (artist->text)
        free(artist->text);

    xml_free_album_browse(artist->albums);
    free(artist);
}

bool xml_parse_browse_album(struct album_browse* a, unsigned char* xml, int len)
{
    ezxml_t top = ezxml_parse_str(xml, len);
    parse_browse_album(top, a);
    ezxml_free(top);

    return true;
}

void xml_free_album(struct album* album)
{
    struct album* next_album = album;
    for (struct album* a = next_album; next_album; a = next_album) {
        next_album = a->next;
        free(a);
    }
}

void xml_free_album_browse(struct album_browse* album)
{
    struct album_browse* next_album = album;
    for (struct album_browse* a = next_album; next_album; a = next_album) {
        xml_free_track(a->tracks);
        next_album = a->next;
        free(a);
    }
}

void xml_parse_prodinfo(struct user_info* u, unsigned char* xml, int len)
{
    ezxml_t top = ezxml_parse_str(xml, len);
    xmlstrncpy(u->type, sizeof u->type, top, "product", 0, "type", -1);
    unsigned int expiry;
    xmlatoi(&expiry, top, "product", 0, "expiry", -1);
    u->expiry = expiry;
    ezxml_free(top);
}

/* Generate a tag with escaped character content. */
char* xml_gen_tag(char* name, char* content)
{
    ezxml_t tag = ezxml_new(name);
    ezxml_set_txt(tag, content);
    char* ret = ezxml_toxml(tag);
    ezxml_free(tag);

    return ret;
}
