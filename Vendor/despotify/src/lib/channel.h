/*
 * $Id: channel.h 100 2009-03-01 13:05:35Z jorgenpt $
 *
 */

#ifndef DESPOTIFY_CHANNEL_H
#define DESPOTIFY_CHANNEL_H

enum channel_state
{
	/* Channel headers */
	CHANNEL_HEADER = 1,

	/* Channel data */
	CHANNEL_DATA = 2,

	/* The last packet, before it's about to be deallocated */
	CHANNEL_END = 4,

	/* If the server signals an error */
	CHANNEL_ERROR = 8
};

struct _channel;
typedef struct _channel CHANNEL;

typedef int (*channel_callback) (CHANNEL *, unsigned char *, unsigned short);
struct _channel
{
	int channel_id;

	unsigned int header_id;
	enum channel_state state;

	unsigned int total_header_len;
	unsigned int total_data_len;

	/* for internal use */
	char name[256];

	/* pointer to private storage */
	void *private;

	/* function pointer */
	channel_callback callback;

	struct _channel *next;
};

CHANNEL *channel_register (char *, channel_callback, void *);
void channel_unregister (CHANNEL *);
CHANNEL *channel_by_id (unsigned short);
int channel_process (unsigned char *, unsigned short, int);
#endif
