/*
 * $Id$
 *
 */

#include <string.h>

#include "buf.h"
#include "channel.h"
#include "commands.h"
#include "gw.h"
#include "gw-image.h"
#include "util.h"

static int gw_image_result_callback (CHANNEL *, unsigned char *,
				     unsigned short);

int gw_image (SPOTIFYSESSION * s, char *id_as_hex)
{
	unsigned char id[20];

	s->output = buf_new ();
	s->output_len = 0;

	hex_ascii_to_bytes (id_as_hex, id, 20);

	return cmd_request_image (s->session, id, gw_image_result_callback,
				  (void *) s);
}

static int gw_image_result_callback (CHANNEL * ch, unsigned char *data,
				     unsigned short len)
{
	SPOTIFYSESSION *s = (SPOTIFYSESSION *) ch->private;
	struct buf *b = s->output;

	/* Ignore those unknown data bytes */
	if (ch->state == CHANNEL_HEADER)
		return 0;

	if (ch->state == CHANNEL_ERROR) {
		s->state = CLIENT_STATE_COMMAND_COMPLETE;

		buf_free (b);

		s->output = NULL;
		s->output_len = -1;

		return 0;
	}
	else if (ch->state == CHANNEL_END) {
		s->state = CLIENT_STATE_COMMAND_COMPLETE;

		s->output_len = b->len;

		return 0;
	}

	buf_append_data (b, data, len);

	return 0;
}
