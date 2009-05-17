/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_COMMANDS_H
#define DESPOTIFY_COMMANDS_H

#include "session.h"
#include "channel.h"

/* Core functionality */
#define CMD_SECRETBLK	0x02
#define CMD_PING	0x04
#define CMD_CHANNELDATA	0x09
#define CMD_CHANNELERR	0x0a
#define CMD_CHANNELABRT	0x0b
#define CMD_REQKEY	0x0c
#define CMD_AESKEY	0x0d
#define CMD_SHAHASH     0x10
#define CMD_IMAGE	0x19
#define CMD_TOKENNOTIFY	0x4f

/* Rights management */
#define CMD_COUNTRYCODE	0x1b

/* P2P related */
#define CMD_P2P_SETUP	0x20
#define CMD_P2P_INITBLK	0x21

/* Search and meta data */
#define CMD_BROWSE		0x30
#define CMD_SEARCH		0x31
#define CMD_GETPLAYLIST		0x35
#define CMD_CHANGEPLAYLIST	0x36

/* Session management */
#define CMD_NOTIFY	0x42
#define CMD_LOG		0x48
#define CMD_PONG	0x49
#define CMD_PONGACK	0x4a
#define CMD_PAUSE	0x4b
#define CMD_REQUESTAD	0x4e
#define CMD_REQUESTPLAY	0x4f

/* Internal */
#define CMD_PRODINFO	0x50
#define CMD_WELCOME	0x69

/* browse types */
#define BROWSE_ARTIST  1
#define BROWSE_ALBUM   2
#define BROWSE_TRACK   3

/* special playlist revision */
#define PLAYLIST_CURRENT	~0

int cmd_send_cache_hash (SESSION *);
int cmd_token_notify (SESSION *);
int cmd_aeskey (SESSION *, unsigned char *, unsigned char *, channel_callback,
		void *);
int cmd_search (SESSION *, char *, unsigned int, unsigned int, channel_callback,
		void *);
int cmd_requestad (SESSION *, unsigned char);
int cmd_request_image (SESSION *, unsigned char *, channel_callback, void *);
int cmd_action (SESSION *, unsigned char *, unsigned char *);
int cmd_getsubstreams (SESSION *, unsigned char *, unsigned int, unsigned int,
		       unsigned int, channel_callback, void *);
int cmd_browse (SESSION *, unsigned char, unsigned char *, int,
		channel_callback, void *);
int cmd_getplaylist (SESSION *, unsigned char *, int, channel_callback,
		     void *);
int cmd_changeplaylist (SESSION *, unsigned char *, char*, int, int, int, int,
			channel_callback, void *);
int cmd_ping_reply (SESSION *);
#endif
