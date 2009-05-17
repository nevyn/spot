/*
 * $Id$
 *
 * Various support routines
 *
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <errno.h>
#include "network.h"

#include "util.h"

unsigned char *hex_ascii_to_bytes (char *ascii, unsigned char *bytes, int len)
{
	int i;
	unsigned int value;

	for (i = 0; i < len; i++) {
		if (sscanf (ascii + 2 * i, "%02x", &value) != 1)
			return NULL;

		bytes[i] = value & 0xff;
	}

	return bytes;
}

char *hex_bytes_to_ascii (unsigned char *bytes, char *ascii, int len)
{
	int i;

	for (i = 0; i < len; i++)
		sprintf (ascii + 2 * i, "%02x", bytes[i]);

	return ascii;
}

void hexdump8x32 (char *prefix, void *data, int len)
{
	fhexdump8x32 (stdout, prefix, data, len);
}

void fhexdump8x32 (FILE * file, char *prefix, void *data, int len)
{
	unsigned char *ptr = (unsigned char *) data;
	int i, j;

	fprintf (file, "%s:%s", prefix,
		 len >= 16 ? "\n" : strlen (prefix) >= 8 ? "\t" : "\t\t");
	for (i = 0; i < len; i++) {
		if (i % 32 == 0)
			printf ("\t");
		fprintf (file, "%02x", ptr[i]);
		if (i % 32 == 31) {
			fprintf (file, " [");
			for (j = i - 31; j <= i; j++)
				fprintf (file, "%c",
					 isprint (ptr[j]) ? ptr[j] : '?');
			fprintf (file, "]\n");
		}
		else if (i % 8 == 7)
			fprintf (file, " ");
	}
	if (i % 32) {
		for (j = i; j % 32; j++)
			fprintf (file, "  %s", j % 8 == 7 ? " " : "");
		fprintf (file, "%s[", j % 8 == 7 ? " " : "");
		for (j = i - i % 32; j < i; j++)
			fprintf (file, "%c", isprint (ptr[j]) ? ptr[j] : '?');
		fprintf (file, "]\n");
	}

	if (!len)
		fprintf (file, "<zero length input>\n");
}

void logdata (char *prefix, int id, void *data, int datalen)
{
	char filename[100];
	FILE *fd;

	sprintf (filename, "spotify.%d.%s.%d", getpid (), prefix, id);
	if ((fd = fopen (filename, "wb")) != NULL) {
		fwrite (data, 1, datalen, fd);
		fclose (fd);
	}

	DSFYDEBUG ("  -- Saving 0x%04x (%d) bytes file '%s'\n", datalen,
		   datalen, filename);
}

ssize_t block_read (int fd, void *buf, size_t nbyte)
{
	unsigned int idx;
	ssize_t n;

	idx = 0;
	while (idx < nbyte) {
		if ((n = sock_recv (fd, buf + idx, nbyte - idx)) <= 0) {
			#ifdef __use_posix__
			if (errno == EINTR)
				continue;
			#endif
			return n;
		}
		idx += n;
	}
	return idx;
}

ssize_t block_write (int fd, void *buf, size_t nbyte)
{
	unsigned int idx;
	ssize_t n;

	idx = 0;
	while (idx < nbyte) {
		if ((n = sock_send (fd, buf + idx, nbyte - idx)) <= 0) {
			#ifdef __use_posix__
			if (errno == EINTR)
				continue;
			#endif
			return n;
		}
		idx += n;
	}
	return idx;
}
