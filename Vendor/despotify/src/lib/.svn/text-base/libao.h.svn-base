/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_LIBAO_H
#define DESPOTIFY_LIBAO_H

#include "audio.h"

enum
{
	AO_IDLE = 0,
	AO_PLAYING,
	AO_PAUSED,
	AO_END
};

typedef struct ao_private
{
	int state;
	pthread_mutex_t lock;	/* Lock for this struct */
	pthread_cond_t pause;	/* condition signal used for pausing */
	pthread_cond_t end;	/* condition signal used when quiting */
	void *device;
} ao_PRIVATE;

int libao_init_device (void *);
int libao_free_device (void);
int libao_prepare_device (AUDIOCTX *);
int libao_play (AUDIOCTX *);
int libao_stop (AUDIOCTX *);

/* Need to be exposed to audio.c, declared in libao.c */
extern AUDIODRIVER *driver;
#endif
