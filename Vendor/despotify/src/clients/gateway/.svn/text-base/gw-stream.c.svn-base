/*
 * $Id$
 *
 */

#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "aes.h"
#include "buf.h"
#include "channel.h"
#include "commands.h"
#include "gw.h"
#include "gw-stream.h"
#include "util.h"

typedef struct
{
	unsigned int offset;
	unsigned int len;
	struct buf *data;

	/* AES CTR state */
	unsigned int state[4 * (10 + 1)];
	unsigned char IV[16];
	unsigned char keystream[16];
} STREAMCTX;

static int gw_file_key_callback (CHANNEL *, unsigned char *, unsigned short);
static int gw_file_stream_callback (CHANNEL *, unsigned char *,
				    unsigned short);

int gw_file_key (SPOTIFYSESSION * s, unsigned char *file_id,
		 unsigned char *track_id)
{
	char buf[40 + 1];
	int i;

	s->output = buf_new ();
	s->output_len = 0;
	buf_append_data (s->output,
			   "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n<filekey>\n",
			   51);

	buf_append_data (s->output, "<file>", 6);
	for (i = 0; i < 20; i++)
		sprintf (buf + 2 * i, "%02x", file_id[i]);
	buf_append_data (s->output, buf, 40);
	buf_append_data (s->output, "</file>\n", 8);

	buf_append_data (s->output, "<track>", 7);
	for (i = 0; i < 16; i++)
		sprintf (buf + 2 * i, "%02x", track_id[i]);
	buf_append_data (s->output, buf, 32);
	buf_append_data (s->output, "</track>\n", 9);

	hexdump8x32 (" file_key, file_id", file_id, 20);
	hexdump8x32 (" file_key, trackid", track_id, 16);

	return cmd_aeskey (s->session, file_id, track_id,
			   gw_file_key_callback, (void *) s);
}

static int gw_file_key_callback (CHANNEL * ch, unsigned char *buf,
				 unsigned short len)
{
	SPOTIFYSESSION *s = (SPOTIFYSESSION *) ch->private;
	struct buf *b = s->output;
	char hexkey[32 + 1];
	int i;

	switch (ch->state) {
	case CHANNEL_DATA:
		buf_append_data (b, "<key>", 5);
		for (i = 0; i < 16 && i < len; i++)
			sprintf (hexkey + 2 * i, "%02x", buf[i]);
		hexkey[32] = 0;
		buf_append_data (b, hexkey, 32);
		buf_append_data (b, "</key>\n", 7);
		buf_append_data (b, "</filekey>\n", 11);
		s->output_len = b->len;
		break;

	case CHANNEL_ERROR:
		buf_free (b);
		s->output = NULL;
		s->output_len = -1;
		break;

		/* Unused */
	case CHANNEL_END:
	default:
		break;
	}

	s->state = CLIENT_STATE_COMMAND_COMPLETE;

	return 0;
}

/*
 * Wrap cmd_getsubstreams() with a custom callback 
 *
 */
int gw_file_stream (SPOTIFYSESSION * s, unsigned char *file_id,
		    unsigned int offset, unsigned int len, unsigned char *key)
{
	int i, j;
	STREAMCTX *sctx;

	sctx = (STREAMCTX *) malloc (sizeof (STREAMCTX));
	if (!sctx)
		return -1;

	if ((sctx->data = buf_new ()) == NULL) {
		free (sctx);
		return -1;
	}

#ifdef DEBUG
	fprintf (stderr, "gw_file_stream() with offset=%u, len=%u\n", offset,
		 len);
#endif

	s->output_len = 0;
	sctx->offset = offset;
	sctx->len = len;

	/* Expand file key */
	rijndaelKeySetupEnc (sctx->state, key, 128);

	/* Set initial IV */
	memcpy (sctx->IV,
		"\x72\xe0\x67\xfb\xdd\xcb\xcf\x77\xeb\xe8\xbc\x64\x3f\x63\x0d\x93",
		16);

	/*
	 * Adjust IV according to the requested starting position.
	 *
	 * Agree'd, this is without doubt the worst code I've ever written. It's late.
	 * Doing it right would probably take less than than I spent writing this comment.
	 *     -- Captain Obvious
	 *       (there's never time to do it right, but always time to do it wrong..)
	 *
	 */
	for (i = 0; i < (int) offset / 16; i++) {
		for (j = 15; j >= 0; j--) {
			sctx->IV[j] += 1;
			if (sctx->IV[j] != 0)
				break;
		}
	}

	s->output = sctx;

	return cmd_getsubstreams (s->session, file_id, offset, len, 200000,
				  gw_file_stream_callback, (void *) s);
}

/*
 * Append encrypted file data to the session's output buffer
 *
 */
static int gw_file_stream_callback (CHANNEL * ch, unsigned char *buf,
				    unsigned short len)
{
	SPOTIFYSESSION *s = (SPOTIFYSESSION *) ch->private;
	STREAMCTX *sctx = (STREAMCTX *) s->output;
	struct buf *b = sctx->data;
	unsigned char *ciphertext, *plaintext;
	unsigned char *w, *x, *y, *z;
	int block, i, j;

	switch (ch->state) {
	case CHANNEL_DATA:
		plaintext = (unsigned char *) malloc (len + 1024);
		assert (plaintext != NULL);

		/* Decrypt each 1024 byte block */
		for (block = 0; block < len / 1024; block++) {

			/* Deinterleave the 4x256 byte blocks */
			ciphertext = plaintext + block * 1024;
			w = buf + block * 1024 + 0 * 256;
			x = buf + block * 1024 + 1 * 256;
			y = buf + block * 1024 + 2 * 256;
			z = buf + block * 1024 + 3 * 256;
			for (i = 0; i < 1024 && (block * 1024 + i) < len;
					i += 4) {
				*ciphertext++ = *w++;
				*ciphertext++ = *x++;
				*ciphertext++ = *y++;
				*ciphertext++ = *z++;
			}

			/* Decrypt 1024 bytes block. This will fail for the last block. */
			for (i = 0; i < 1024 && (block * 1024 + i) < len;
					i += 16) {
				/* Produce 16 bytes of keystream from the IV */
				rijndaelEncrypt (sctx->state, 10, sctx->IV,
						 sctx->keystream);

				/* Update IV counter. This loop is an awesome construction! */
				for (j = 15; j >= 0; j--) {
					sctx->IV[j] += 1;
					if (sctx->IV[j] != 0)
						break;
				}

				/* Produce plaintext by XORing ciphertext with keystream */
				for (j = 0; j < 16; j++)
					plaintext[block * 1024 + i + j] ^=
						sctx->keystream[j];
			}
		}

		buf_append_data (b, plaintext, len);
		free (plaintext);
		break;

	case CHANNEL_ERROR:
		s->state = CLIENT_STATE_COMMAND_COMPLETE;
		buf_free (b);
		free (sctx);
		s->output = NULL;
		s->output_len = -1;
		break;

	case CHANNEL_END:
		s->state = CLIENT_STATE_COMMAND_COMPLETE;
		free (s->output);
		s->output = b;
		s->output_len = b->len;
		break;

	default:
		break;
	}

	return 0;
}
