/*
 * $Id$
 *
 * This file contains a basic implementations of request
 * you may send to Spotify's service.
 *
 */

#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "buf.h"
#include "channel.h"
#include "commands.h"
#include "packet.h"
#include "util.h"

/*
 * Writes to /tmp
 *
 */
static int dump_generic (CHANNEL * ch, unsigned char *buf, unsigned short len)
{
	FILE *fd;
	char filename[512];

	if (len == 0)
		return 0;

	if (ch->state == CHANNEL_HEADER)
		snprintf (filename, sizeof (filename),
			  "/tmp/channel-%d-%s.hdr-%d", ch->channel_id,
			  ch->name, ch->header_id);
	else
		snprintf (filename, sizeof (filename), "/tmp/channel-%d-%s",
			  ch->channel_id, ch->name);

	if ((fd = fopen (filename, "ab")) != NULL) {
		fwrite (buf, 1, len, fd);
		fclose (fd);

		return 0;
	}

	return -1;
}

int cmd_send_cache_hash (SESSION * session)
{
	int ret;
        struct buf* buf = buf_new();
	buf_append_data(buf, session->cache_hash, sizeof (session->cache_hash));

	ret = packet_write (session, 0x0f, buf->ptr, buf->len);
	DSFYDEBUG ("cmd_send_cache_hash: packet_write() returned %d\n", ret);
	buf_free(buf);

	return ret;
}

/*
 * Request ads
 * The response is plain XML
 *
 */
int cmd_requestad (SESSION * session, unsigned char ad_type)
{
	CHANNEL *ch;
	int ret;
	char buf[100];
        struct buf* b = buf_new();

	snprintf (buf, sizeof (buf), "RequestAd-with-type-%d", ad_type);
	ch = channel_register (buf, dump_generic, NULL);

	DSFYDEBUG
		("cmd_requestad: allocated channel %d, retrieving ads with type id %d\n",
		 ch->channel_id, ad_type);

        buf_append_u16(b, ch->channel_id);
	buf_append_u8(b, ad_type);

	ret = packet_write (session, CMD_REQUESTAD, b->ptr, b->len);
	DSFYDEBUG ("cmd_requestad: packet_write() returned %d\n", ret);

	buf_free(b);

	return ret;
}

/*
 * Request image using a 20 byte hash
 * The response is a JPG
 *
 */
int cmd_request_image (SESSION * session, unsigned char *hash,
		       channel_callback callback, void *private)
{
	CHANNEL *ch;
	int ret;
	char buf[100];
        struct buf* b = buf_new();

	strcpy (buf, "image-");
	hex_bytes_to_ascii (hash, buf + 6, 20);

	ch = channel_register (buf, callback, private);
	DSFYDEBUG
		("cmd_requestimg: allocated channel %d, retrieving img with UUID %s\n",
		 ch->channel_id, buf + 6);

	buf_append_u16(b, ch->channel_id);
	buf_append_data(b, hash, 20);

	ret = packet_write (session, CMD_IMAGE, b->ptr, b->len);
	DSFYDEBUG ("cmd_requestimg: packet_write() returned %d\n", ret);
            
        buf_free(b);
	
	return ret;
}

/*
 * Search music
 * The response comes as compressed XML
 *
 */
int cmd_search (SESSION * session, char *searchtext, unsigned int offset,
		unsigned int limit, channel_callback callback, void *private)
{
	CHANNEL *ch;
	int ret;
	char buf[100];
	unsigned char searchtext_length;

	assert (limit);

	struct buf* b = buf_new();

	snprintf (buf, sizeof (buf), "Search-%s", searchtext);
	ch = channel_register (buf, callback, private);

	DSFYDEBUG ("cmd_search: allocated channel %d, searching for '%s'\n",
		   ch->channel_id, searchtext);

	buf_append_u16(b, ch->channel_id);
	buf_append_u32(b, offset);
	buf_append_u32(b, limit);
	buf_append_u16(b, 0);

	searchtext_length = (unsigned char) strlen (searchtext);
	buf_append_u8(b, searchtext_length);
	buf_append_data(b, searchtext, searchtext_length);

	ret = packet_write (session, CMD_SEARCH, b->ptr, b->len);
	DSFYDEBUG ("cmd_search: packet_write() returned %d\n", ret)

	buf_free(b);
	
	return ret;
}

/*
 * Notify server we're going to play
 *
 */
int cmd_token_notify (SESSION * session)
{
	int ret;
	
	ret = packet_write (session, CMD_TOKENNOTIFY, NULL, 0);
	if (ret != 0) {
		DSFYDEBUG
			("cmd_token_notify(): packet_write(cmd=0x4f) returned %d, aborting!\n",
			 ret)
	}

	return ret;
}

int cmd_aeskey (SESSION * session, unsigned char *file_id,
		unsigned char *track_id, channel_callback callback,
		void *private)
{
	int ret;
	CHANNEL *ch;
	char buf[256];

	/* Request the AES key for this file by sending the file ID and track ID */
	struct buf* b = buf_new();
	buf_append_data(b, file_id, 20);
	buf_append_data(b, track_id, 16);
	buf_append_u16(b, 0);

	/* Allocate a channel and set its name to key-<file id> */
	strcpy (buf, "key-");
	hex_bytes_to_ascii (file_id, buf + 4, 20);
	ch = channel_register (buf, callback, private);
	DSFYDEBUG
		("cmd_key(): allocated channel %d, retrieving AES key for file '%.40s'\n",
		 ch->channel_id, buf);

	/* Force DATA state to be able to handle these packets with the channel infrastructure */
	ch->state = CHANNEL_DATA;
	buf_append_u16(b, ch->channel_id);

	ret = packet_write (session, CMD_REQKEY, b->ptr, b->len);
	buf_free(b);
	if (ret != 0) {
		DSFYDEBUG
			("cmd_key(): packet_write(cmd=0x0c) returned %d, aborting!\n",
			 ret)
	}

	return ret;
}

/*
 * A demo wrapper for playing a track
 *
 */
int cmd_action (SESSION * session, unsigned char *file_id,
		unsigned char *track_id)
{
	int ret;

	/*
	 * Notify the server about our intention to play music, there by allowing
	 * it to request other players on the same account to pause.
	 *
	 * Yet another client side restriction to annoy those who share their 
	 * Spotify account with not yet invited friends.
	 * And as a bonus it won't play commercials and waste bandwidth in vain.
	 *
	 */
	if ((ret =
	     packet_write (session, CMD_REQUESTPLAY, (unsigned char *) "",
			   0)) != 0) {
		DSFYDEBUG
			("cmd_action(): packet_write(0x4f) returned %d, aborting!\n",
			 ret)
			return ret;
	}

#ifdef P2P
	/* Request a 100 byte P2P initialization block */
	struct buf* b = buffer_new();
	buf_append_data(b, file_id, 20);

	ret = packet_write (session, 0x20, b->ptr, b->len);
	bufr_free(b);
	if (ret != 0) {
		DSFYDEBUG
			("cmd_action(): packet_write(cmd=0x20) returned %d, aborting!\n",
			 ret);
                return ret;
	}
#endif

	/* Request the AES key for this file by sending the file ID and track ID */
	return cmd_aeskey (session, file_id, track_id, dump_generic, NULL);
}

/*
 * Request a part of the encrypted file from the server.
 *
 * The data should be decrypted using the AES in CTR mode
 * with AES key provided and a static IV, incremeted for
 * each 16 byte data processed.
 *
 */
int cmd_getsubstreams (SESSION * session, unsigned char *file_id,
		       unsigned int offset, unsigned int length,
		       unsigned int unknown_200k, channel_callback callback,
		       void *private)
{
	char buf[512];
	CHANNEL *ch;
	int ret;

	hex_bytes_to_ascii (file_id, buf, 20);
	ch = channel_register (buf, callback, private);
	DSFYDEBUG
		("cmd_getsubstreams: allocated channel %d, retrieving song '%s'\n",
		 ch->channel_id, ch->name);

        struct buf* b = buf_new();
	buf_append_u16(b, ch->channel_id);

	/* I have no idea wtf these 10 bytes are for */
	buf_append_u16(b, 0x0800);
	buf_append_u16(b, 0x0000);
	buf_append_u16(b, 0x0000);
	buf_append_u16(b, 0x0000);
	buf_append_u16(b, 0x4e20); /* drugs are bad for you, m'kay? */
	buf_append_u32(b, unknown_200k);
	buf_append_data(b, file_id, 20);

	assert (offset % 4096 == 0);
	assert (length % 4096 == 0);
	offset >>= 2;
	length >>= 2;
	buf_append_u32(b, offset);
	buf_append_u32(b, offset + length);

	hex_bytes_to_ascii (file_id, buf, 20);
	DSFYDEBUG
		("Sending GetSubstreams(file_id=%s, offset=%u [%u bytes], length=%u [%u bytes])\n",
		 buf, offset, offset << 2, length, length << 2);

	ret = packet_write (session, 0x08, b->ptr, b->len);
	DSFYDEBUG("1\n");
	buf_free(b);

	if (ret != 0) {
		channel_unregister (ch);
		DSFYDEBUG
			("cmd_getsubstreams(): packet_write(cmd=0x08) returned %d, aborting!\n",
			 ret);
	}

	DSFYDEBUG("end\n");
	return ret;
}

/*
 * Get metadata for an artist (kind=1), an album (kind=2)  or a list of tracks (kind=3)
 * The response comes as compressed XML
 *
 */
int cmd_browse (SESSION * session, unsigned char kind, unsigned char *idlist,
		int num, channel_callback callback, void *private)
{
	CHANNEL *ch;
	char buf[256];
	int i, ret;

	assert (((kind == BROWSE_ARTIST || kind == BROWSE_ALBUM) && num == 1)
		|| kind == BROWSE_TRACK);

	strcpy (buf, "browse-");
	hex_bytes_to_ascii(idlist, buf + 7, 16);
	ch = channel_register (buf, callback, private);

	struct buf* b = buf_new();
	buf_append_u16(b, ch->channel_id);
	buf_append_u8(b, kind);

	for (i = 0; i < num; i++)
		buf_append_data(b, idlist + i * 16, 16);

	if (kind == BROWSE_ARTIST) {
		assert (num == 1);
		buf_append_u32(b, 0);
	}

	if ((ret =
	     packet_write (session, CMD_BROWSE, b->ptr, b->len)) != 0) {
		DSFYDEBUG
			("cmd_browse(): packet_write(cmd=0x30) returned %d, aborting!\n",
			 ret)
	}

	buf_free(b);

	return ret;
}

/*
 * Request playlist details
 * The response comes as plain XML
 *
 */
int cmd_getplaylist (SESSION * session, unsigned char *playlist_id,
		     int revision, channel_callback callback, void *private)
{
	CHANNEL *ch;
	char buf[256];
	int ret;

	strcpy (buf, "playlist-");
	hex_bytes_to_ascii (playlist_id, buf + 9, 17);
	buf[9 + 2 * 17] = 0;
	ch = channel_register (buf, callback, private);

	struct buf* b = buf_new();
	buf_append_u16(b, ch->channel_id);
	buf_append_data(b, playlist_id, 17);
	buf_append_u32(b, revision);
	buf_append_u32(b, 0);
	buf_append_u32(b, 0xffffffff);
	buf_append_u8(b, 0x1);

	if ((ret =
	     packet_write (session, CMD_GETPLAYLIST, b->ptr, b->len)) != 0) {
		DSFYDEBUG
			("cmd_getplaylist(): packet_write(cmd=0x35) returned %d, aborting!\n",
			 ret);
	}

	buf_free(b);
	
	return ret;
}

/*
 * Modify playlist
 * The response comes as plain XML
 */
int cmd_changeplaylist (SESSION * session, unsigned char *playlist_id,
			char *xml, int revision, int num_tracks, int checksum,
			int collaborative, channel_callback callback,
			void *private)
{
	CHANNEL *ch;
	char buf[256];
	int ret;

	strcpy (buf, "chplaylist-");
	hex_bytes_to_ascii (playlist_id, buf + 11, 17);
	buf[11 + 2 * 17] = 0;
	ch = channel_register (buf, callback, private);

	struct buf* b = buf_new();
	buf_append_u16(b, ch->channel_id);
	buf_append_data(b, playlist_id, 17);
	buf_append_u32(b, revision);
	buf_append_u32(b, num_tracks);
	buf_append_u32(b, checksum);	/* -1=create playlist */
	buf_append_u8(b, collaborative);
	buf_append_u8(b, 3);		/* Unknown */
        buf_append_data(b, xml, strlen(xml));

	if ((ret =
	     packet_write (session, CMD_CHANGEPLAYLIST, b->ptr, b->len)) != 0) {
		DSFYDEBUG ("cmd_changeplaylist(): packet_write(cmd=0x36) "
			   "returned %d, aborting!\n", ret);
	}

	buf_free(b);

	return ret;
}

int cmd_ping_reply (SESSION * session)
{
	int ret;
        unsigned long pong = 0;

	if ((ret = packet_write (session, CMD_PONG, (void*)&pong, 4)) != 0) {
		DSFYDEBUG
			("cmd_ping_reply(): packet_write(cmd=0x49) returned %d, aborting!\n",
			 ret);
	}

	return ret;
}
