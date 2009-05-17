/*
 * $Id$
 *
 */

#include <string.h>

#include "base64.h"

static char table[] =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static int b64idx (int c)
{
	char *p = strchr (table, c);

	if (!p)
		p = table;

	return p - table;
}

void b64decode (char *in, char *out)
{
	int len = strlen (in);
	unsigned int q;

	if (len % 4)
		return;

	while (*in) {
		q = b64idx (*in++);
		q = q << 6 | b64idx (*in++);
		q = q << 6 | b64idx (*in++);
		q = q << 6 | b64idx (*in++);
		*out++ = (q >> 16) & 0xff;
		*out++ = (q >> 8) & 0xff;
		*out++ = q & 0xff;
	}
}
