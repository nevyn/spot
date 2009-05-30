/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_UTIL_H
#define DESPOTIFY_UTIL_H

#include <pthread.h>
#include <sys/times.h>
#include <unistd.h>

#ifdef DEBUG
#define DSFYDEBUG(...) { FILE *fd = fopen("/tmp/gui.log","at"); fprintf(fd, "%s:%d %s() ", __FILE__, __LINE__, __func__); fprintf(fd, __VA_ARGS__); fclose(fd); }
#else
#define DSFYDEBUG(...)
#endif

#ifdef DEBUG_SNDQUEUE
#define DSFYDEBUG_SNDQUEUE(...) DSFYDEBUG(__VA_ARGS__)
#else
#define DSFYDEBUG_SNDQUEUE(...)
#endif

#define DSFYfree(p) do { free(p); (p) = NULL; } while (0)
#define DSFYstrncat(target, data, size) do { strncat(target, data, size-1); ((unsigned char*)target)[size-1] = 0; } while (0)
#define DSFYstrncpy(target, data, size) do { strncpy(target, data, size-1); ((unsigned char*)target)[size-1] = 0; } while (0)

unsigned char *hex_ascii_to_bytes (char *, unsigned char *, int);
char *hex_bytes_to_ascii (unsigned char *, char *, int);
void hexdump8x32 (char *, void *, int);
void fhexdump8x32 (FILE *, char *, void *, int);
void logdata (char *, int, void *, int);
ssize_t block_read (int, void *, size_t);
ssize_t block_write (int, void *, size_t);
#endif
