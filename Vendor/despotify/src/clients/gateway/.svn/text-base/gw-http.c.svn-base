/*
 * $Id$
 * Process HTTP requests
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "network.h"

#include "base64.h"
#include "buf.h"
#include "gw.h"
#include "gw-http.h"


static int http_reply (RESTSESSION *, int, struct buf *);
static int http_reply_need_auth (RESTSESSION *);
static void http_cleanup (RESTSESSION * r);
static int http_complete_login (RESTSESSION *);

static char content_type[] = "Content-Type: text/html; charset=utf-8\r\n";
static char connection_close[] = "Connection: close\r\n";

int http_handle_request (RESTSESSION * r)
{
	struct buf *b;
	char buf[512];
	char *p;
	SPOTIFYSESSION *client;

	/*
	 * r->httpreq->url has path that was requested
	 * r->httpreq->authheader MIGHT be non-NULL and 
	 * have username:password in base64
	 *
	 */

	/* Default to process next command */
	r->state = REST_STATE_LOAD_COMMAND;

	if ((client = spotify_find_http_client ()) == NULL) {
		/* Force auth if not sent or likely invalid */
		if (!r->httpreq->authheader
				|| strlen (r->httpreq->authheader) > 100)
			return http_reply_need_auth (r);

		memset (buf, 0, sizeof (buf));
		b64decode (r->httpreq->authheader, buf);
		if ((p = strchr (buf, ':')) == NULL) {
			printf ("b64 decode failed '%s'\n", buf);
			return http_reply_need_auth (r);
		}

		*p++ = 0;
		strcpy (r->username, buf);
		strcpy (r->password, p);
		spotify_client_allocate (r);
		spotify_client_mark_for_http (r->client);
		if (r->client->state == CLIENT_STATE_IDLE_CONNECTED)
			return http_complete_login (r);

		r->state = REST_STATE_WAITING;
		r->httpreq->callback = http_complete_login;
		return 0;
	}

	if (0) {

	}
	else {
		b = buf_new ();
		sprintf (buf,
			 "You're logged in as '%s' with password '%s'<br />\n",
			 r->username, r->password);
		if (client)
			buf_append_data(b, buf, strlen (buf));
		sprintf (buf, "The requested URL '%s' was not found!\n",
			 r->httpreq->url);
		buf_append_data(b, buf, strlen (buf));
		return http_reply (r, 404, b);
	}

	return 0;
}

static void http_cleanup (RESTSESSION * r)
{
	if (r->httpreq->authheader)
		free (r->httpreq->authheader);

	free (r->httpreq->url);
	free (r->httpreq);
	r->httpreq = NULL;
}

static int http_reply_need_auth (RESTSESSION * r)
{
	struct buf *b;
	int ret;
	char buf[256];

	b = buf_new();
	strcpy (buf, "HTTP/1.1 401\r\n");
	buf_append_data (b, buf, strlen (buf));
	strcpy (buf, "WWW-Authenticate: Basic realm=\"Spotify\"\r\n");
	buf_append_data (b, buf, strlen (buf));
	buf_append_data (b, content_type, strlen (content_type));
	buf_append_data (b, connection_close, strlen (connection_close));
	strcpy (buf, "Content-Length: 0\r\n");
	buf_append_data (b, buf, strlen (buf));
	buf_append_data (b, "\r\n", 2);

	ret = 0;
	if (sock_send (r->socket, b->ptr, b->len) != b->len)
		ret = -1;

	buf_free (b);
	http_cleanup (r);

	return ret;
}

static int http_reply (RESTSESSION * r, int status, struct buf * response)
{
	struct buf *b;
	int ret;
	char respcode[100];
	char content_len[256];

	b = buf_new ();
	sprintf (respcode, "HTTP/1.1 %03d\r\n", status);
	buf_append_data (b, respcode, strlen (respcode));
	buf_append_data (b, content_type, strlen (content_type));
	buf_append_data (b, connection_close, strlen (connection_close));
	sprintf (content_len, "Content-Length: %d\r\n", response->len);
	buf_append_data (b, content_len, strlen (content_len));
	buf_append_data (b, "\r\n", 2);
	buf_append_data (b, response->ptr, response->len);

	ret = 0;
	if (sock_send (r->socket, b->ptr, b->len) != b->len)
		ret = -1;

	buf_free (b);
	buf_free (response);
	http_cleanup (r);

	return ret;
}

static int http_complete_login (RESTSESSION * r)
{
	struct buf *response;

	if (r->client->state != CLIENT_STATE_IDLE_CONNECTED)
		return http_reply_need_auth (r);

	response = buf_new ();
	buf_append_data (response, "logged in!\n", 11);

	return http_reply (r, 200, response);
}
