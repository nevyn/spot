/*
 * $Id: ui-search.c 254 2009-03-26 12:33:43Z dstien $
 *
 */

#include <string.h>
#include <assert.h>

#include <curses.h>

#include "buf.h"
#include "channel.h"
#include "commands.h"
#include "despotify.h" 
#include "ui.h"
#include "ui-playlist.h"
#include "ui-search.h"
#include "util.h"
#include "xml.h"

struct reqcontext
{
	WINDOW *win;
        struct buf *response;
	struct playlist *playlist;
	unsigned char *track_id_list;
};

static int gui_search_result_callback (CHANNEL *, unsigned char *,
				       unsigned short);

int gui_search (SESSION * ctx, WINDOW * w, char *searchtext)
{
	struct reqcontext *r;
	char buf[256];

	r = (struct reqcontext *) malloc (sizeof (struct reqcontext));
	r->win = w;
	r->response = buf_new ();
	r->playlist = playlist_new ();
	snprintf (buf, sizeof (buf), "Search: %s", searchtext);
	buf[sizeof (buf) - 1] = 0;
	playlist_set_name (r->playlist, buf);
	playlist_set_author (r->playlist, ctx->username);

	mvwprintw (w, 1, 1, " ");

	return cmd_search (ctx, searchtext, 0, 100,
			   gui_search_result_callback, r);
}

static int gui_search_result_callback (CHANNEL * ch, unsigned char *buf,
				       unsigned short len)
{
	struct reqcontext *r = (struct reqcontext *) ch->private;
	int skip_len;

	/* Ignore those unknown data bytes */
	if (ch->state == CHANNEL_HEADER)
		return 0;

	/* Present result and cleanup if done */
	if (ch->state == CHANNEL_END) {
		r->playlist->flags |= PLAYLIST_LOADED;

		/* Add tracks */
		playlist_track_update_from_gzxml (r->playlist,
						  r->response->ptr,
						  r->response->len);

		/* Since this is a newly added playlist we know it's the first one */
		playlist_select (1);

		/* Display it! */
		gui_playlist_display (r->win, r->playlist);

		/* Refresh the header listing the number of playlists */
		event_msg_post (MSG_CLASS_GUI, MSG_GUI_REFRESH, NULL);

		return 0;
	}

	/* Skip a minimal gzip header */
	if (ch->total_data_len < 10) {
		skip_len = 10 - ch->total_data_len;
		while (skip_len && len) {
			skip_len--;
			len--;
			buf++;
		}

		if (len == 0)
			return 0;
	}

	buf_append_data (r->response, buf, len);

	/* Parse more data */
	wprintw (r->win, "..");
	wrefresh (r->win);

	return 0;
}
