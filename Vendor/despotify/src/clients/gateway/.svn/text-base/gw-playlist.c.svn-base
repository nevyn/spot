/*
 * $Id$
 *
 */

#include <stdio.h>
#include <string.h>

#include "buf.h"
#include "channel.h"
#include "commands.h"
#include "gw.h"
#include "gw-playlist.h"
#include "util.h"

static int gw_getplaylist_result_callback (CHANNEL *, unsigned char *,
					   unsigned short);

int gw_getplaylist (SPOTIFYSESSION * s, char *playlist_hex_id)
{
	unsigned char id[17];

	hex_ascii_to_bytes (playlist_hex_id, id, 17);

	s->output = buf_new ();
	s->output_len = 0;
	buf_append_data (s->output,
			   "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<playlist>\n",
			   51);

	return cmd_getplaylist (s->session, id, PLAYLIST_CURRENT,
				gw_getplaylist_result_callback, (void *) s);
}

static int gw_getplaylist_result_callback (CHANNEL * ch, unsigned char *buf,
					   unsigned short len)
{
	SPOTIFYSESSION *s = (SPOTIFYSESSION *) ch->private;
	struct buf *b = s->output;

	switch (ch->state) {
	case CHANNEL_DATA:
		buf_append_data (b, buf, len);
		break;

	case CHANNEL_ERROR:
		s->state = CLIENT_STATE_COMMAND_COMPLETE;

		buf_free (b);
		s->output = NULL;
		s->output_len = -1;
		break;

	case CHANNEL_END:
		s->state = CLIENT_STATE_COMMAND_COMPLETE;

		buf_append_data (b, "\n</playlist>", 12);
		s->output_len = b->len;
		break;

	default:
		break;
	}

	return 0;
}
