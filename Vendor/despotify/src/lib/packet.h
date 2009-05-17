/*
 * $Id: packet.h 182 2009-03-12 08:21:53Z zagor $
 *
 */

#ifndef DESPOTIFY_PACKET_H
#define DESPOTIFY_PACKET_H

#include "session.h"

/*
 * Packet header
 *
 */
struct packet_header
{
	unsigned char cmd;
	unsigned short len;
} __attribute__ ((packed));
typedef struct packet_header PHEADER;

/* lowlevel packet functions */
int packet_read (SESSION * c, PHEADER *, unsigned char **);
int packet_write (SESSION *, unsigned char, unsigned char *, unsigned short);
#endif
