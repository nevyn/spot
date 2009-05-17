/*
 * $Id: ui-playlist.h 229 2009-03-22 18:02:04Z jorgenpt $
 *
 */

#ifndef DESPOTIFY_UI_PLAYLIST_H
#define DESPOTIFY_UI_PLAYLIST_H

#include <curses.h>

#include "event.h"
#include "despotify.h" 

void gui_playlist (WINDOW *, char *);
void gui_playlist_display (WINDOW *, struct playlist *);
int gui_playlists_download (EVENT *, enum ev_flags);
#endif
