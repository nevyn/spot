/*
 * $Id$
 *
 *
 */

#ifndef DESPOTIFY_GW_H
#define DESPOTIFY_GW_H

#include <time.h>
#include <zlib.h>

#include "buf.h"
#include "session.h"

enum client_state_t
{
	CLIENT_STATE_IDLE_DISCONNECTED,
	CLIENT_STATE_ALLOCATE,
	CLIENT_STATE_CONNECT,
	CLIENT_STATE_KEY_EXCHANGE,
	CLIENT_STATE_AUTH,
	CLIENT_STATE_IDLE_CONNECTED,
	CLIENT_STATE_LOGIN_COMPLETE,
	CLIENT_STATE_COMMAND_COMPLETE,
	CLIENT_STATE_ERROR_CONNECT,
	CLIENT_STATE_ERROR_KEY_EXCHANGE,
	CLIENT_STATE_ERROR_AUTH,
	CLIENT_STATE_ERROR_PACKET
};

/*
 * Holds a connection to Spotify
 *
 */
typedef struct
{
	char client_id[41];

	enum client_state_t state;
	SESSION *session;
	int client_has_data;
	time_t last_activity;

	char username[256];
	char password[256];

	void *output;
	int output_len;

	/*
	 * Cheap hack for finding a client for the HTTP requests
	 * Provides no security what so ever. :)
	 *
	 */
	int is_http_client;
} SPOTIFYSESSION;

typedef struct
{
	struct buf *b;
	z_stream z;
	int decompression_done;
} DECOMPRESSCTX;

/*
 * For keeping track of HTTP requests
 *
 */
struct _RESTSESSION;
typedef struct
{
	char *url;
	char *authheader;
	int (*callback) (struct _RESTSESSION *);
	int state;
} HTTPREQUEST;

enum rest_state_t
{
	REST_STATE_READING,
	REST_STATE_LOAD_COMMAND,
	REST_STATE_PROCESS_INIT_COMMAND,
	REST_STATE_PROCESS_CLIENT_COMMAND,
	REST_STATE_PROCESS_HTTP_REQUEST,
	REST_STATE_WAITING,
	REST_STATE_FREE_CLIENT
};

/*
 * An incoming connection to be used as a 
 * gateway to the Spotify service
 *
 */
struct _RESTSESSION
{
	enum rest_state_t state;
	int socket;
	int socket_has_data;
	time_t last_activity;

	char input[8192];
	int input_len;

	char command[8192];

	char username[256];
	char password[256];

	HTTPREQUEST *httpreq;

	SPOTIFYSESSION *client;
};
typedef struct _RESTSESSION RESTSESSION;

int rest_fsm (RESTSESSION *);
int spotify_fsm (SPOTIFYSESSION *);
int spotify_client_allocate (RESTSESSION *);
int spotify_client_mark_for_http (SPOTIFYSESSION *);
SPOTIFYSESSION *spotify_find_http_client (void);
#endif
