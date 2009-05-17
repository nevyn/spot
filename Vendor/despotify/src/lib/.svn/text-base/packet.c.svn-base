/*
 * $Id$
 *
 * Deal with reading and writing packets
 * and packet processing
 *
 */

#include <stdio.h>
#include <string.h>
#include "network.h"
#include <unistd.h>
#include <time.h>
#include <assert.h>

#include "session.h"
#include "channel.h"
#include "commands.h"
#include "packet.h"
#include "util.h"

int packet_read (SESSION * session, PHEADER * h, unsigned char **payload)
{
	int ret;
	int packet_len;
	unsigned char nonce[4];
	unsigned char *ptr;

	packet_len = 0;
	if ((ret = block_read (session->ap_sock, h, 3)) != 3) {
		DSFYDEBUG
			("packet_read(): read short count %d, expected 3 (header)\n",
			 ret);
		return -1;
	}

	*(unsigned int *) nonce = htonl (session->key_recv_IV);
	shn_nonce (&session->shn_recv, nonce, 4);

	shn_decrypt (&session->shn_recv, (unsigned char *) h, 3);

#ifdef DEBUG_PACKETS
	DSFYDEBUG ("packet_read(): cmd=%d [0x%02x], len=%d [0x%04x]\n",
		   h->cmd, h->cmd, ntohs (h->len), ntohs (h->len));
	logdata ("recv-hdr", session->key_recv_IV, (unsigned char *) h, 3);
#endif

	/* Length of payload */
	h->len = ntohs (h->len);
	packet_len = h->len;

	/* Account for MAC */
	packet_len += 4;

	ptr = (unsigned char *) malloc (packet_len);
	if ((*payload = ptr) == NULL)
		return -1;

	if ((ret =
	     block_read (session->ap_sock, ptr, packet_len)) != packet_len) {
		DSFYDEBUG
			("packet_read(cmd=0x%02x): read short count %d, expected %d\n",
			 h->cmd, ret, packet_len);
		return -1;
	}

	shn_decrypt (&session->shn_recv, *payload, packet_len);

#ifdef DEBUG_PACKETS
	logdata ("recv-dec", session->key_recv_IV, *payload, h->len);
#endif

	/* Increment IV */
	session->key_recv_IV++;

	return 0;
}

int packet_write (SESSION * session, unsigned char cmd,
		  unsigned char *payload, unsigned short len)
{
	unsigned char nonce[4];
	unsigned char *buf, *ptr;
	PHEADER *h;
	int ret;

	*(unsigned int *) nonce = htonl (session->key_send_IV);
	shn_nonce (&session->shn_send, nonce, 4);

	buf = (unsigned char *) malloc (3 + len + 4);

	h = (PHEADER *) buf;
	h->cmd = cmd;
	h->len = htons (len);

	ptr = buf + 3;
	if (payload != NULL)
	{
 		memcpy (ptr, payload, len);
	}
	
#ifdef DEBUG_PACKETS
	DSFYDEBUG
		("packet_write(): Sending packet with command 0x%02x, length %d\n",
		 h->cmd, ntohs (h->len));
	logdata ("send-hdr", session->key_send_IV, (unsigned char *) h, 3);
	if (payload != NULL) logdata ("send-payload", session->key_send_IV, payload, len);
#endif

	shn_encrypt (&session->shn_send, buf, 3 + len);
	ptr += len;

	shn_finish (&session->shn_send, ptr, 4);

	ret = block_write (session->ap_sock, buf, 3 + len + 4);

	free(buf);

	session->key_send_IV++;


	if(ret != 3 + len + 4) {
#ifdef DEBUG_PACKETS
		DSFYDEBUG ("packet_write(): only wrote %d of %d bytes\n", ret,
			   3 + len + 4);
#endif
		return -1;
	}

	return 0;
}
