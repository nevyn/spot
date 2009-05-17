/*
 * $Id: coreaudio.h 100 2009-03-01 13:05:35Z jorgenpt $
 *
 */

#ifndef DESPOTIFY_COREAUDIO_H
#define DESPOTIFY_COREAUDIO_H

#include "audio.h"

int coreaudio_init_device (void *);
int coreaudio_free_device (void *);
int coreaudio_prepare_device (AUDIOCTX *);
int coreaudio_play (AUDIOCTX *);
int coreaudio_stop (AUDIOCTX *);
#endif
