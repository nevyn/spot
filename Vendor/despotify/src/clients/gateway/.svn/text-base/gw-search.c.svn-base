/*
 * $Id$
 *
 */

#include <string.h>
#include <assert.h>

#include "buf.h"
#include "channel.h"
#include "commands.h"
#include "gw.h"
#include "gw-search.h"

static int gw_search_result_decompress (DECOMPRESSCTX *, unsigned char *,
					unsigned short);
static int gw_search_result_callback (CHANNEL *, unsigned char *,
				      unsigned short);

int gw_search (SPOTIFYSESSION * s, char *searchtext)
{
	DECOMPRESSCTX *dctx;

	dctx = (DECOMPRESSCTX *) malloc (sizeof (DECOMPRESSCTX));

	dctx->z.zalloc = Z_NULL;
	dctx->z.zfree = Z_NULL;
	dctx->z.opaque = Z_NULL;
	dctx->z.avail_in = 0;
	dctx->z.next_in = Z_NULL;
	if (inflateInit2 (&dctx->z, -MAX_WBITS) != Z_OK) {
		free (dctx);
		return -1;
	}

	dctx->b = buf_new ();

	s->output = dctx;
	s->output_len = 0;

	return cmd_search (s->session, searchtext, 0, 100,
			   gw_search_result_callback, (void *) s);
}

static int gw_search_result_callback (CHANNEL * ch, unsigned char *buf,
				      unsigned short len)
{
	SPOTIFYSESSION *s = (SPOTIFYSESSION *) ch->private;
	DECOMPRESSCTX *dctx = (DECOMPRESSCTX *) s->output;
	int skip_len;

	/* Ignore those unknown data bytes */
	if (ch->state == CHANNEL_HEADER)
		return 0;

	if (ch->state == CHANNEL_ERROR) {
		s->state = CLIENT_STATE_COMMAND_COMPLETE;

		inflateEnd (&dctx->z);
		buf_free (dctx->b);
		free (dctx);

		s->output = NULL;
		s->output_len = -1;

		return 0;
	}
	else if (ch->state == CHANNEL_END) {
		s->state = CLIENT_STATE_COMMAND_COMPLETE;

		/*
		 * Return the buffer with the uncompressed XML
		 * in ->output
		 *
		 */
		s->output = dctx->b;
		s->output_len = dctx->b->len;

		free (dctx);

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

	/* Parse more data */
	return gw_search_result_decompress (dctx, buf, len);
}

#define CHUNKSZ   65536
static int gw_search_result_decompress (DECOMPRESSCTX * dctx,
					unsigned char *data,
					unsigned short len)
{
	int e;
	int ret;

	dctx->z.next_in = data;
	dctx->z.avail_in = len;

	ret = 1;
	do {
		buf_extend (dctx->b, CHUNKSZ);
		dctx->z.avail_out = dctx->b->size - dctx->b->len;
		dctx->z.next_out = dctx->b->ptr + dctx->b->len;

		e = inflate (&dctx->z, Z_NO_FLUSH);
		if (e != Z_OK && e != Z_STREAM_END)
			break;

		dctx->b->len = dctx->z.total_out;
	} while (dctx->z.avail_out == 0);

	dctx->z.next_in = Z_NULL;
	dctx->z.next_out = Z_NULL;

	if (e == Z_OK && ret == 1)
		return 0;

	/* XXX - Upper layer doesn't handle the error at the moment,
	   will crash if it's free'd before last packet */
	inflateEnd (&dctx->z);

	return Z_STREAM_END - e;

}
