/*
 * $Id$
 *
 * Generic audio output driver interface
 * ...or at least that was the idea before we went into
 * Spy vs. Spy mode and started nuking each other's code. ;)
 *
 * For now it does its job with support from the drivers.
 * Everyone's happy!! :)
 *
 */

#include <stdlib.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <vorbis/vorbisfile.h>

#include "audio.h"
#include "sndqueue.h"
#include "util.h"

/* Initialize audio output device */
int audio_init (void)
{
	int ret;

	/* Initialize audio hardware */
	if ((ret = driver->register_hw (NULL)))
		return ret;

	return 0;
}

/* Release audio output device */
int audio_release (void)
{

	return driver->unregister_hw ();
}

/* Prepare audio output device for playing */
AUDIOCTX *audio_context_new (float samplerate, int channels, char *title)
{
	AUDIOCTX *a;
	int ret;

	if ((a = (AUDIOCTX *) malloc (sizeof (AUDIOCTX))) == NULL)
		return NULL;

	/* Initialize the whole structure to zero. */
	memset (a, 0, sizeof (AUDIOCTX));

	a->samplerate = samplerate;
	a->channels = channels;

	/* Originally intended for PA, not used */
	if (title)
		a->title = strdup (title);

	DSFYDEBUG
		("audio_context_new(): Calling the driver's prepare() function to setup samplerate and channels..\n")
		if ((ret = driver->prepare (a)) != 0) {
		DSFYDEBUG
			("audio_context_new(): the driver's prepare() failed :(\n")
			if (a->title)
			free (a->title);

		free (a);

		return NULL;
	}

	return a;
}

/* Stop playing and free audio context */
int audio_context_free (AUDIOCTX * a)
{
	int ret;

	ret = 0;
	if (a->is_playing)
		ret = driver->stop (a);

	if (a->title)
		free (a->title);

	free (a);

	return ret;
}

/* Start playing; make sure there's buffered data available! */
int audio_play (AUDIOCTX * a)
{
	int ret;

	if (a->is_playing) {
		a->is_playing = 0;
		if ((ret = driver->stop (a)))
			return ret;
	}

	DSFYDEBUG ("audio_play(): calling driver's ->play() routine..\n")
		a->is_playing = 1;

	return driver->play (a);
}

/* Stop playing */
int audio_stop (AUDIOCTX * a)
{
	int ret = 0;

	if (a->is_playing) {
		DSFYDEBUG
			("audio_stop(): now calling driver's ->stop() routine..\n")

			a->is_playing = 0;
		ret = driver->stop (a);
	}

	return ret;
}

/* Pause audio */
int audio_pause (AUDIOCTX * a)
{
	if (!a->is_playing)
		return 0;

	DSFYDEBUG ("audio_pause(): calling driver's ->pause() routine..\n")

		a->is_paused = 1;

	return driver->pause (a);
}

/* resume playing */
int audio_resume (AUDIOCTX * a)
{
	if (!a->is_playing)
		return 0;

	DSFYDEBUG
		("audio_resume(): now calling driver's ->resume() routine..\n")

		a->is_paused = 0;

	return driver->resume (a);
}
