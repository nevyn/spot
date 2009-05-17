/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_PULSEAUDIO_H
#define DESPOTIFY_PULSEAUDIO_H

#include "audio.h"

enum
{
	PU_IDLE = 0,
	PU_PLAYING,
	PU_PAUSED,
	PU_END
};

typedef struct pa_private
{
	int state;
	pthread_mutex_t lock;	/* Lock for this struct */
	pthread_cond_t pause;	/* condition signal used for pausing */
	pthread_cond_t end;	/* condition signal used when quiting */
	void *pa_simple;
} pa_PRIVATE;

int pulseaudio_init_device (void *);
int pulseaudio_free_device (void);
int pulseaudio_prepare_device (AUDIOCTX *);
int pulseaudio_play (AUDIOCTX *);
int pulseaudio_stop (AUDIOCTX *);
#endif
