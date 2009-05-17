/*
 * $Id: gw-handlers.c 182 2009-03-12 08:21:53Z zagor $
 *
 */

#include "gw.h"
#include "gw-handlers.h"

/*
 * Snoop on country packets
 *
 */

/* TODO

int gw_handle_countrycode(PHANDLER *ph, unsigned char *payload, unsigned short len) {
        int ret;
        int i;
	SPOTIFYSESSION *s = (SPOTIFYSESSION *)ph->private;

        for(i = 0; i < len && i < sizeof(s->country); i ++)
                s->country[i] = payload[i];

        s->country[i] = 0;

        return ret;
}

*/
