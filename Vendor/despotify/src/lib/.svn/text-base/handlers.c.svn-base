/*
 * $Id$
 *
 * Default handlers for different types of commands
 *
 */

#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "network.h"
#include <assert.h>

#include "channel.h"
#include "commands.h"
#include "packet.h"
#include "util.h"
#include "xml.h"

int handle_secret_block (SESSION * session, unsigned char *payload, int len)
{
	unsigned int *t;

	if (len != 336) {
		DSFYDEBUG ("Got cmd=0x02 with len %d, expected 336!\n", len);
		return -1;
	}

	t = (unsigned int *) payload;
	DSFYDEBUG
		("handle_secret_block(): Initial time %u (%ld seconds from now)\n",
		 ntohl (*t), time (NULL) - ntohl (*t));
	t++;
	DSFYDEBUG
		("handle_secret_block(): Invalid at %u (%ld in the future)\n",
		 ntohl (*t), ntohl (*t) - time (NULL));

	t++;
	DSFYDEBUG ("handle_secret_block(): Next value is %u\n", ntohl (*t));
	t++;
	DSFYDEBUG ("handle_secret_block(): Next value is %u\n", ntohl (*t));

	assert (memcmp (session->rsa_pub_exp, payload + 16, 128) == 0);

	/* At payload+16+128 is a  144 bytes (1536-bit) RSA signature */

	/*
	 * Actually the cache hash is sent before the server has sent any
	 * packets. It's just put here out of convenience, because this is
	 * one of the first packets ever by the server, and also not
	 * repeated during a session.
	 *
	 */

	return cmd_send_cache_hash (session);
}

int handle_ping (SESSION * session, unsigned char *payload, int len)
{

	/* Store timestamp and respond to the request */
	time_t t;
	assert (len == 4);
	memcpy (&t, payload, 4);
	session->user_info.last_ping = ntohl (t);

	return cmd_ping_reply (session);
}

int handle_channel (int cmd, unsigned char *payload, int len)
{
	if (cmd == CMD_CHANNELERR) {
		DSFYDEBUG
			("handle_channel_error: Channel %d got error %d (0x%02x)\n",
			 ntohs (*(unsigned short *) payload),
			 ntohs (*(unsigned short *) (payload + 2)),
			 ntohs (*(unsigned short *) (payload + 2)))
	}
	
	return channel_process (payload, len, cmd == CMD_CHANNELERR);
}

int handle_aeskey (unsigned char *payload, int len)
{
	CHANNEL *ch;
	int ret;

	DSFYDEBUG ("Server said 0x0d (AES key) for channel %d\n",
		   ntohs (*(unsigned short *) (payload + 2)))
		if ((ch =
		     channel_by_id (ntohs
				    (*(unsigned short *) (payload + 2)))) !=
			   NULL) {
		ret = ch->callback (ch, payload + 4, len - 4);
		channel_unregister (ch);
	}
	else {
		DSFYDEBUG
			("Command 0x0d: Failed to find channel with ID %d\n",
			 ntohs (*(unsigned short *) (payload + 2)));
	}

	return ret;
}

static int handle_countrycode (SESSION * session, unsigned char *payload, int len)
{
	int i;
	for (i = 0; i < len && i < (int)sizeof session->user_info.country; i++)
		session->user_info.country[i] = payload[i];
	session->user_info.country[i] = 0;
	return 0;
}

static int handle_prodinfo (SESSION * session, unsigned char *payload, int len)
{
	xml_parse_prodinfo(&session->user_info, payload, len);
	return 0;
}

static int handle_welcome (SESSION * session)
{
    /* signal "login complete" */
    pthread_mutex_lock(&session->login_mutex);
    pthread_cond_signal(&session->login_cond);
    pthread_mutex_unlock(&session->login_mutex);
    return 0;
}

int handle_packet (SESSION * session,
		   int cmd, unsigned char *payload, int len)
{
	int error = 0;

	switch (cmd) {
	case CMD_SECRETBLK:
		error = handle_secret_block (session, payload, len);
		break;

	case CMD_PING:
		error = handle_ping (session, payload, len);
		break;

	case CMD_CHANNELDATA:
		error = handle_channel (cmd, payload, len);
		break;

	case CMD_CHANNELERR:
		error = handle_channel (cmd, payload, len);
		break;

	case CMD_AESKEY:
		error = handle_aeskey (payload, len);
		break;

	case CMD_SHAHASH:
		break;

	case CMD_COUNTRYCODE:
		error = handle_countrycode (session, payload, len);
		break;

	case CMD_P2P_INITBLK:
		DSFYDEBUG ("Server said 0x21 (P2P initalization block)\n")
			break;

	case CMD_NOTIFY:
		/* HTML-notification, shown in a yellow bar in the official client */
		break;

	case CMD_PRODINFO:
		/* Payload is uncompressed XML */
		error = handle_prodinfo (session, payload, len);
		break;

	case CMD_WELCOME:
		error = handle_welcome (session);
		break;

	case CMD_PAUSE:
		/* TODO: No GUI events in here.
		event_msg_post (MSG_CLASS_GUI, MSG_GUI_PAUSE, NULL);
		*/
		break;
	}

	return error;
}
