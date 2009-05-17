/*
 * $Id$
 *
 * This is a gateway to the Spotify server, intended for use 
 * in combination with scripted services or HTTP REST.
 *
 * The idea is to establish a session once and then to be
 * able to reconnect to it later to perform additional
 * commands.
 *
 * The protocol is pretty simple.
 *
 * Supported commands;
 * IN INITIAL STATE (WITHOUT CLIENT)
 * - login <user> <pass>		(login as <user> and <pass>)
 * - session <id of existing session>	(reconnect to session <id>)
 * - quit				(disconnect from gateway)
 * IN CONNECTED STATE (WITH A CONNECTED CLIENT)
 * - id					(dump Spotify client's session id)
 * - country				(dump Spotify client's assigned country)
 * - search <text>			(dump uncompressed XML from a search)
 * - image <20 byte id in hex>		(dump image for ID)
 * - browsetrack <16 byte id in hex>	(dump track info for ID)
 * - browsealbum <16 byte id in hex>	(dump album info for ID)
 * - browseartist <16 byte id in hex>	(dump artist info for ID)
 * - playlist <17 byte id in hex>	(dump XML for playlist with ID)
 * - logout				(logout Spotify client from server)
 * - quit				(disconnect from gateway)
 *
 * The output is in the form of
 * <HTTP-style error code> <payload length> <OK/WARN/ERROR> <description>\n
 * [eventual payload goes after the linebreak]
 *
 *
 * There is also some very basic support for acting like an ordinary
 * HTTP-server. It was added to allow serving Spotify playlists as
 * M3U or XSPF files, with the song URIs pointing to the gateway.
 * It would make it possible to play content from Spotify in third
 * party music players such as XMMS or Winamp.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <time.h>
#include <assert.h>

#include "network.h"
#include "auth.h"
#include "commands.h"
#include "dns.h"
#include "gw.h"
#include "gw-browse.h"
#include "gw-handlers.h"
#include "gw-http.h"
#include "gw-image.h"
#include "gw-playlist.h"
#include "gw-search.h"
#include "gw-stream.h"
#include "handlers.h"
#include "keyexchange.h"
#include "packet.h"
#include "session.h"
#include "util.h"

#define SPOTIFYSESSION_TIMEOUT	600

int rest_fsm (RESTSESSION *);
int spotify_fsm (SPOTIFYSESSION *);

/* Global variables for keeping track of sessions to Spotify */
static SPOTIFYSESSION **client;
static int num_clients;

int main (int argc, char **argv)
{
	
    if (network_init() != 0) return -1;

	RESTSESSION **rest;
	int num_rest;

	struct sockaddr_in sin;
	fd_set rfds;
	struct timeval tv;
	int max_fd;
	int i, j;
	int ret;
	int listen_fd;
	time_t t;
	int ok_to_idle;

	if (argc != 3) {
		fprintf (stderr, "Usage: %s <bind address> <bind port>\n",
			 argv[0]);
		return -1;
	}

	memset (&sin, 0, sizeof (sin));
	sin.sin_family = PF_INET;
	if ((sin.sin_port = htons (atoi (argv[2]))) == 0) {
		fprintf (stderr, "* Invalid port '%s'\n", argv[2]);
		return -1;
	}

	if ((sin.sin_addr.s_addr = dns_resolve_name (argv[1])) == INADDR_NONE) {
		fprintf (stderr, "* Failed to resolve '%s'\n", argv[1]);
		return -1;
	}

	listen_fd = socket (PF_INET, SOCK_STREAM, IPPROTO_TCP);
	ret = 1;
	setsockopt (listen_fd, SOL_SOCKET, SO_REUSEADDR, &ret, sizeof (ret));
	if (bind (listen_fd, (struct sockaddr *) &sin, sizeof (sin)) < 0) {
		fprintf (stderr, "* Failed to bind to '%s:%s'\n", argv[1],
			 argv[2]);
		return -1;
	}

	listen (listen_fd, 5);

#ifdef DEBUG
	printf ("* Successfully bound to %s:%s\n", argv[1], argv[2]);
#endif

	rest = NULL;
	num_rest = 0;
	client = NULL;
	num_clients = 0;
	do {
		t = time (NULL);
		ok_to_idle = 1;

		/* Do stuff */
		for (i = 0; i < num_rest; i++) {
			ret = 0;
			if (rest[i]->socket_has_data)
				rest[i]->last_activity = t;

			if (rest_fsm (rest[i]) == 0) {
				/*
				 * Optimization; don't hang around in select()
				 * waiting for data when there's FSM work to do!
				 *
				 */
				if (rest[i]->state != REST_STATE_READING)
					ok_to_idle = 0;

				continue;
			}

			sock_close (rest[i]->socket);
			free (rest[i]);

			/* Replace this daemon session with the last one */
			rest[i] = rest[--num_rest];
			break;
		}

		for (i = 0; i < num_clients; i++) {
			if (client[i]->client_has_data)
				client[i]->last_activity = t;

			if (client[i]->last_activity +
					SPOTIFYSESSION_TIMEOUT > t) {
				if (spotify_fsm (client[i]) == 0) {
					if (client[i]->state !=
							CLIENT_STATE_IDLE_CONNECTED
							&& client[i]->state !=
							CLIENT_STATE_COMMAND_COMPLETE)
						ok_to_idle = 0;
					continue;
				}
			}

			printf ("Dropping a dead (%ld seconds old, max allowed=%u) or failed Spotify connection (id %s)\n", t - client[i]->last_activity, SPOTIFYSESSION_TIMEOUT, client[i]->client_id);

			for (j = 0; j < num_rest; j++) {
				if (rest[j]->client != client[i])
					continue;

				/*
				 * Drop client from active connection
				 * XXX - It's pretty mean to do with without
				 * any notifications
				 *
				 */
				rest[j]->client = NULL;
				rest[j]->state = REST_STATE_LOAD_COMMAND;
			}

#ifdef DEBUG
			printf ("main(): Free'ing SPOTIFYSESSION\n");
#endif

			session_free (client[i]->session);
			free (client[i]);
			client[i] = client[--num_clients];
		}

		FD_ZERO (&rfds);
		FD_SET (listen_fd, &rfds);
		max_fd = listen_fd;

		for (i = 0; i < num_rest; i++) {
			FD_SET (rest[i]->socket, &rfds);
			if (rest[i]->socket > max_fd)
				max_fd = rest[i]->socket;
		}

		for (i = 0; i < num_clients; i++) {
			if (client[i]->session->ap_sock == -1)
				continue;

			FD_SET (client[i]->session->ap_sock, &rfds);
			if (client[i]->session->ap_sock > max_fd)
				max_fd = client[i]->session->ap_sock;
		}

		/* Allow for some context switches */
		tv.tv_usec = 1000 * 50;
		tv.tv_sec = 0;
		if (ok_to_idle)
			tv.tv_sec = 60;

		if ((ret = select (max_fd + 1, &rfds, NULL, NULL, &tv)) < 0)
			break;
		else if (ret == 0)
			continue;

		if (FD_ISSET (listen_fd, &rfds)) {
			if ((ret = accept (listen_fd, NULL, NULL)) < 0)
				continue;

			if ((rest =
			     realloc (rest,
				      (num_rest +
				       1) * sizeof (RESTSESSION *))) == NULL)
				exit (1);

			rest[num_rest] = malloc (sizeof (RESTSESSION));
			rest[num_rest]->state = REST_STATE_READING;
			rest[num_rest]->socket = ret;
			rest[num_rest]->socket_has_data = 0;
			rest[num_rest]->last_activity = time (NULL);
			rest[num_rest]->input_len = 0;
			rest[num_rest]->client = NULL;
			rest[num_rest]->httpreq = NULL;
			num_rest++;
			continue;
		}

		/*
		 * Update info about readble sockets
		 *
		 */
		for (i = 0; i < num_rest; i++)
			if (FD_ISSET (rest[i]->socket, &rfds))
				rest[i]->socket_has_data = 1;

		for (i = 0; i < num_clients; i++)
			if (client[i]->session->ap_sock != -1
					&& FD_ISSET (client[i]->
						     session->ap_sock, &rfds))
				client[i]->client_has_data = 1;

	} while (1);

	for (i = 0; i < num_rest; i++) {
		close (rest[i]->socket);
		free (rest[i]);
	}
	free (rest);

	for (i = 0; i < num_clients; i++) {
		session_free (client[i]->session);
		free (client[i]);
	}

	free (client);

	return 0;
}

int rest_read_input (RESTSESSION * r)
{
	int ret;
	int nbytes_to_read;

	do {
		nbytes_to_read = sizeof (r->input) - r->input_len;
		/* Drop connection if the buffer gets filled up */
		if (nbytes_to_read == 0)
			return -1;

		ret = recv (r->socket, r->input + r->input_len, nbytes_to_read, 0);
		if (ret <= 0) {
			printf("rest_read_input(): read returned %d\n", ret);
			return -1;
		}

		r->input_len += ret;
		if (ret != nbytes_to_read)
			break;
	} while (1);

	return 0;
}

int rest_fsm (RESTSESSION * r)
{
	int ret;
	int len;
	int i;
	void *ptr;
	char msg[1024];
	char temp[1024], temp2[256];
	unsigned char file_id[20], track_id[16], key[16];
	unsigned int offset, length;

#ifdef DEBUG
	printf ("rest_fsm(): Entering with gateway client %p (spotify %s) in state %d\n", (void *) r, r->client ? r->client->client_id : "<unassigned>", r->state);
#endif

	ret = 0;
	switch (r->state) {
	case REST_STATE_READING:
		if (!r->socket_has_data)
			break;

		r->socket_has_data = 0;
		r->state = REST_STATE_LOAD_COMMAND;
		if ((ret = rest_read_input (r)) != 0) 
			break;

	case REST_STATE_LOAD_COMMAND:
		/* Extract a line without the trailing \n (or \r\n) */
		if ((ptr = memchr (r->input, '\n', r->input_len)) == NULL) {
			r->state = REST_STATE_READING;
			break;
		}

		/* Copy line without trailing '\n' to r->command */
		len = (char *) ptr - r->input;
		memcpy (r->command, r->input, len);
		r->command[len] = 0;

		/* Move additional data to beginning of buffer */
		r->input_len -= len + /* '\n' */ 1;
		memmove (r->input, r->input + len + 1, r->input_len);

		/* Zap '\r' */
		if (len && r->command[len - 1] == '\r')
			len--;
		r->command[len] = 0;

		/* Process command by upgrading the state */
		if (r->httpreq) {
			/* Handle HTTP headers separately */
			r->state = REST_STATE_PROCESS_HTTP_REQUEST;
		}
		else if (len > 0) {
			r->state = REST_STATE_PROCESS_INIT_COMMAND;
			if (r->client != NULL)
				r->state = REST_STATE_PROCESS_CLIENT_COMMAND;
		}
		break;

	case REST_STATE_PROCESS_INIT_COMMAND:
		if (!strcmp (r->command, "quit")) {
			ret = -1;
			sprintf (msg, "200 0 OK Shutting down\n");
			block_write (r->socket, msg, strlen (msg));
		}
		else if (sscanf (r->command, "GET %255s HTTP/1.", temp) == 1) {
			ret = -1;
			if ((r->httpreq =
			     malloc (sizeof (HTTPREQUEST))) != NULL) {
				temp[255] = 0;
				r->httpreq->url = strdup (temp);
				r->httpreq->authheader = NULL;
				r->httpreq->callback = NULL;
				r->httpreq->state = 0;
				ret = 0;
			}

			/* Let REST_STATE_LOAD_COMMAND handle header processing */
			r->state = REST_STATE_LOAD_COMMAND;
		}
		else if ((ret =
			  sscanf (r->command, "login %255s %255s",
				  r->username, r->password)) == 2) {
			r->username[sizeof (r->username) - 1] = 0;
			r->password[sizeof (r->password) - 1] = 0;

			ret = spotify_client_allocate (r);
			if (r->client->state != CLIENT_STATE_ALLOCATE) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "200 0 OK Found previous session with this username and password\n");
				if (block_write (r->socket, msg,
						 strlen (msg)) !=
						(int) strlen (msg))
					ret = -1;
			}
		}
		else if (sscanf (r->command, "session %40s", temp) == 1) {
			for (i = 0; i < num_clients; i++) {
				if (strcmp (client[i]->client_id, temp))
					continue;

				r->client = client[i];
				break;
			}

			r->state = REST_STATE_LOAD_COMMAND;
			if (r->client)
				sprintf (msg,
					 "200 0 OK Client with id '%.100s' found\n",
					 temp);
			else
				sprintf (msg,
					 "404 0 WARN Client with id '%.100s' NOT found\n",
					 temp);

			if (block_write (r->socket, msg,
					 strlen (msg)) != (int) strlen (msg))
				ret = -1;
		}
		else {
			r->state = REST_STATE_LOAD_COMMAND;
			sprintf (msg, "501 0 WARN Invalid command '%.100s'\n",
				 r->command);
			if (block_write (r->socket, msg,
					 strlen (msg)) != (int) strlen (msg))
				ret = -1;
		}
		break;

	case REST_STATE_PROCESS_HTTP_REQUEST:
		assert (r->httpreq != NULL);
		if (strlen (r->command) == 0) {
			/* Process HTTP request */
			printf ("Calling http_handle_request()\n");
			ret = http_handle_request (r);
		}
		else {
			if (!strncasecmp (r->command, "Authorization: Basic ",
					  21)) {
				if (r->httpreq->authheader)
					free (r->httpreq->authheader);

				r->httpreq->authheader =
					strdup (r->command + 21);
			}

			/* Process next command (might be a HTTP header) */
			r->state = REST_STATE_LOAD_COMMAND;
		}

		break;

	case REST_STATE_PROCESS_CLIENT_COMMAND:
		if (!strcmp (r->command, "quit")) {
			ret = -1;
			sprintf (msg, "200 0 OK Shutting down\n");
			block_write (r->socket, msg, strlen (msg));
		}
		else if (!strcmp (r->command, "logout")) {
			r->state = REST_STATE_FREE_CLIENT;

			sprintf (msg, "200 0 OK Disconnecting client\n");
			block_write (r->socket, msg, strlen (msg));
		}
		else if (!strcmp (r->command, "id")) {
			r->state = REST_STATE_LOAD_COMMAND;
			sprintf (msg,
				 "200 %zd OK The session id is shown below\n%s",
				 strlen (r->client->client_id),
				 r->client->client_id);
			block_write (r->socket, msg, strlen (msg));
		}
		else if (!strcmp (r->command, "country")) {
			r->state = REST_STATE_LOAD_COMMAND;
			sprintf (msg, "200 %zd OK Assigned country below\n%s",
				 strlen (r->client->session->user_info.country),
				 r->client->session->user_info.country);
			block_write (r->socket, msg, strlen (msg));
		}
		else if (!strncmp (r->command, "browseartist ", 13)) {
			if (strlen (r->command) != 13 + 2 * 16) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN Artist ID must be provided in hex as 32 characters\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_browse (r->client, 1,
						r->command + 13, 1)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else if (!strncmp (r->command, "browsealbum ", 12)) {
			if (strlen (r->command) != 12 + 2 * 16) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN Album ID must be provided in hex as 32 characters\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_browse (r->client, 2,
						r->command + 12, 1)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else if (!strncmp (r->command, "browsetrack ", 12)) {
			if (strlen (r->command + 12) % (2 * 16) != 0 || strlen (r->command + 12) / (2 * 16) > 128 || strlen(r->command + 12) < 32) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN Track ID must be provided in hex as 32[,64,96,128,..] characters\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_browse (r->client, 3,
						r->command + 12, strlen(r->command + 12) / 32)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else if (!strncmp (r->command, "image ", 6)) {
			if (strlen (r->command) != 6 + 2 * 20) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN Image ID must be provided in hex as 40 characters\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_image (r->client,
					       r->command + 6)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else if (!strncmp (r->command, "search ", 7)) {
			r->state = REST_STATE_WAITING;
			if ((ret =
			     gw_search (r->client, r->command + 7)) != 0)
				r->state = REST_STATE_FREE_CLIENT;
		}
		else if (sscanf (r->command, "key %40s %32s", temp,
				 temp2) == 2) {
			temp[40] = temp2[32] = 0;

			if (strlen (temp) != 40 || strlen (temp2) != 32) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN File ID must be provided in hex as 40 character and track ID must be provided in hex as 32 characters\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				hex_ascii_to_bytes (temp, file_id, 20);
				hex_ascii_to_bytes (temp2, track_id, 16);

				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_file_key (r->client, file_id,
						  track_id)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else if (sscanf (r->command, "substream %40s %u %u %32s",
				 temp, &offset, &length, temp2) == 4) {
			temp[40] = temp2[32] = 0;

			if (strlen (temp) != 40 || (offset % 1024) != 0
					|| len == 0 || strlen (temp2) != 32) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN File IDs must be provided in hex as 40 characters, offset must be in 1024 byte chunks, length mustn't be zero and key must be provided in hex as 32 characters.\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				hex_ascii_to_bytes (temp, file_id, 20);
				hex_ascii_to_bytes (temp2, key, 16);

				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_file_stream (r->client, file_id,
						     offset, length,
						     key)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else if (!strncmp (r->command, "playlist ", 9)) {
			if (strlen (r->command) != 9 + 2 * 17) {
				r->state = REST_STATE_LOAD_COMMAND;
				sprintf (msg,
					 "501 0 WARN Playlist IDs must be in hex and need to be 34 characters long\n");
				block_write (r->socket, msg, strlen (msg));
			}
			else {
				r->state = REST_STATE_WAITING;
				if ((ret =
				     gw_getplaylist (r->client,
						     r->command + 9)) != 0)
					r->state = REST_STATE_FREE_CLIENT;
			}
		}
		else {
			r->state = REST_STATE_LOAD_COMMAND;
			sprintf (msg,
				 "501 0 WARN Unknown command or bad parameters; '%.100s'\n",
				 r->command);
			if (block_write (r->socket, msg, strlen (msg)) <= 0)
				ret = -1;
		}
		break;

	case REST_STATE_WAITING:
		assert (r->client != NULL);

		printf ("In waiting, spotify session state is %d\n",
			r->client->state);
		switch (r->client->state) {
		case CLIENT_STATE_COMMAND_COMPLETE:
			r->state = REST_STATE_LOAD_COMMAND;
			r->client->state = CLIENT_STATE_IDLE_CONNECTED;
			if (r->client->output != NULL) {
				if (!r->httpreq) {
					sprintf (msg,
						 "200 %d OK Command completed successfully\n",
						 r->client->output_len);
					block_write (r->socket, msg,
						     strlen (msg));
					if (block_write (r->socket,
							 ((struct buf*)
							  r->client->
							  output)->ptr,
							 ((struct buf*)
							  r->client->
							  output)->len) <=
							0)
						ret = -1;

				}
				else
					ret = r->httpreq->callback (r);

				buf_free ((struct buf*) r->client->output);
			}
			else {
				if (!r->httpreq) {
					sprintf (msg,
						 "500 0 ERROR Command failed to execute\n");
					if (block_write (r->socket, msg,
							 strlen (msg)) <= 0)
						ret = -1;
				}
				else
					ret = r->httpreq->callback (r);
			}
			break;

		case CLIENT_STATE_LOGIN_COMPLETE:
			r->state = REST_STATE_LOAD_COMMAND;;
			r->client->state = CLIENT_STATE_IDLE_CONNECTED;
			if (!r->httpreq) {
				sprintf (msg, "200 0 OK Login successful\n");
				if (block_write (r->socket, msg,
						 strlen (msg)) !=
						(int) strlen (msg))
					ret = -1;
			}
			else
				ret = r->httpreq->callback (r);

			break;

		case CLIENT_STATE_IDLE_CONNECTED:
			break;

		case CLIENT_STATE_ERROR_CONNECT:
			r->state = REST_STATE_FREE_CLIENT;
			r->client->state = CLIENT_STATE_IDLE_DISCONNECTED;
			if (!r->httpreq) {
				sprintf (msg,
					 "503 0 WARN Client failed to connect\n");
				if (block_write (r->socket, msg,
						 strlen (msg)) !=
						(int) strlen (msg))
					ret = -1;
			}
			else
				ret = r->httpreq->callback (r);

			break;

		case CLIENT_STATE_ERROR_KEY_EXCHANGE:
			r->state = REST_STATE_FREE_CLIENT;
			r->client->state = CLIENT_STATE_IDLE_DISCONNECTED;
			if (!r->httpreq) {
				sprintf (msg,
					 "404 0 WARN Key exchange failed (bad username?)\n");
				if (block_write (r->socket, msg,
						 strlen (msg)) !=
						(int) strlen (msg))
					ret = -1;
			}
			else
				ret = r->httpreq->callback (r);

			break;

		case CLIENT_STATE_ERROR_AUTH:
			r->state = REST_STATE_FREE_CLIENT;
			r->client->state = CLIENT_STATE_IDLE_DISCONNECTED;
			if (!r->httpreq) {
				sprintf (msg,
					 "403 0 WARN Authentication failed (bad password?)\n");
				if (block_write (r->socket, msg,
						 strlen (msg)) !=
						(int) strlen (msg))
					ret = -1;
			}
			else
				ret = r->httpreq->callback (r);

			break;

		default:
			assert (0);
			break;
		}

		break;

	case REST_STATE_FREE_CLIENT:

#ifdef DEBUG
		printf ("rest_fsm(): Got request to kill and free client\n");
#endif

		for (i = 0; i < num_clients; i++)
			if (r->client == client[i])
				break;
		assert (i < num_clients);
		if (client[i]->session)
			session_free (client[i]->session);

		free (client[i]);
		client[i] = client[--num_clients];

		r->client = NULL;
		r->state = REST_STATE_LOAD_COMMAND;
	}

#ifdef DEBUG
	printf ("rest_fsm(): Leaving with gateway client %p (spotify %s) in state %d, ret value is %d\n", (void *) r, r->client ? r->client->client_id : "<unassigned>", r->state, ret);
	/*
	 */
#endif

	return ret;
}

int spotify_fsm (SPOTIFYSESSION * s)
{
	PHEADER hdr;
	unsigned char *payload;
	int ret;

#ifdef DEBUG
	printf ("spotify_fsm(): Entering with Spotify client %s in state %d\n", s->client_id, s->state);
#endif

	ret = 0;
	switch (s->state) {
	case CLIENT_STATE_IDLE_DISCONNECTED:
		break;

	case CLIENT_STATE_ALLOCATE:
		if ((s->session = session_init_client ()) == NULL) {
			s->state = CLIENT_STATE_ERROR_CONNECT;
			break;
		}

		s->state = CLIENT_STATE_CONNECT;

	case CLIENT_STATE_CONNECT:
		s->state = CLIENT_STATE_KEY_EXCHANGE;
		session_auth_set (s->session, s->username, s->password);
		if (session_connect (s->session)) {
			s->state = CLIENT_STATE_ERROR_CONNECT;
			break;
		}

	case CLIENT_STATE_KEY_EXCHANGE:
		s->state = CLIENT_STATE_AUTH;
		if (do_key_exchange (s->session)) {
			s->state = CLIENT_STATE_ERROR_KEY_EXCHANGE;
			break;
		}

	case CLIENT_STATE_AUTH:
		auth_generate_auth_hash (s->session);
		key_init (s->session);

		s->state = CLIENT_STATE_LOGIN_COMPLETE;
		if (do_auth (s->session)) {
			s->state = CLIENT_STATE_ERROR_AUTH;
		}
		break;

	case CLIENT_STATE_IDLE_CONNECTED:
		if (s->client_has_data) {
			s->client_has_data = 0;
			if ((ret =
			     packet_read (s->session, &hdr, &payload)) != 0) {
				s->state = CLIENT_STATE_ERROR_PACKET;
				break;
			}
			ret = handle_packet (s->session, hdr.cmd, payload,
					     hdr.len);
			free (payload);	/* Allocated in packet_read() */
			payload = NULL;
			if (ret != 0) {
				s->state = CLIENT_STATE_ERROR_PACKET;
				break;
			}

		}
		break;

	case CLIENT_STATE_LOGIN_COMPLETE:
	case CLIENT_STATE_COMMAND_COMPLETE:
		/*
		 * Wait for a REST session to lift us out of this state
		 * During this no other commands are processed :(
		 *
		 */
		break;

	case CLIENT_STATE_ERROR_CONNECT:
	case CLIENT_STATE_ERROR_KEY_EXCHANGE:
	case CLIENT_STATE_ERROR_AUTH:
	case CLIENT_STATE_ERROR_PACKET:
	default:
		break;
	}

#ifdef DEBUG
	/*
	 */
	printf ("spotify_fsm(): Leaving with Spotify client %s in state %d\n",
		s->client_id, s->state);
#endif

	return ret;
}

/*
 * Setup r->client by either creating a new session or by finding an
 * existing one with the same name and password.
 *
 * If a new one is created, r->state is set to REST_STATE_WAITING until
 * the session to Spotify fail or succeeds.
 *  
 */
int spotify_client_allocate (RESTSESSION * r)
{
	int i;

	/* Prevent multiple connections on the same account */
	for (i = 0; i < num_clients; i++) {
		if (strcmp (client[i]->username, r->username)
				|| strcmp (client[i]->password, r->password))
			continue;

		r->client = client[i];
		break;
	}

	/* Only allocate a new one if no existing connection was found */
	if (i == num_clients) {
		client = realloc (client,
				  (num_clients +
				   1) * sizeof (SPOTIFYSESSION *));
		client[num_clients] =
			(SPOTIFYSESSION *) malloc (sizeof (SPOTIFYSESSION));
		client[num_clients]->session = NULL;
		sprintf (client[num_clients]->client_id, "%08lx%x",
			 (unsigned int) time (NULL) ^ getpid () ^
			 (((unsigned long) client) << 7 & 0xffffffff),
			 num_clients + 1);
		client[num_clients]->state = CLIENT_STATE_ALLOCATE;
		client[num_clients]->is_http_client = 0;
		client[num_clients]->client_has_data = 0;
		client[num_clients]->last_activity = time (NULL);

		strcpy (client[num_clients]->username, r->username);
		strcpy (client[num_clients]->password, r->password);

		r->client = client[num_clients];

		num_clients++;

		r->state = REST_STATE_WAITING;
	}

	return 0;
}

/* Hacks for gw-http.c */
int spotify_client_mark_for_http (SPOTIFYSESSION * s)
{
	if (!s)
		return -1;

	s->is_http_client = 1;

	return 0;
}

SPOTIFYSESSION *spotify_find_http_client (void)
{
	int i;

	for (i = 0; i < num_clients; i++)
		if (client[i]->is_http_client)
			return client[i];

	return NULL;
}

void app_packet_callback (SESSION * s, int cmd, unsigned char *payload,
			  int len)
{
	(void) s;
	(void) cmd;
	(void) payload;
	(void) len;
}
