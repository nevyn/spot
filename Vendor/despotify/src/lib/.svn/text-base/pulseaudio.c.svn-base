/*
 * $Id$
 *
 * Linux PulseAudio audio output driver for Despotify
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <errno.h>

#include <pulse/simple.h>
#include <pulse/error.h>

#include "audio.h"
#include "sndqueue.h"
#include "pulseaudio.h"
#include "util.h"

/*
 * Initialize and get an output device
 *
 */
int pulseaudio_init_device (void *unused)
{
	(void) unused;		/* don't warn */
	/* N/A */

	return 0;
}

/*
 * Prepare for playback by configuring sample rate, channels, ..
 * 
 */
int pulseaudio_prepare_device (AUDIOCTX * actx)
{

	pa_sample_spec ss;
	int error;
	pa_simple *s = NULL;
	pa_PRIVATE *priv;

	/* The Sample format to use */
	ss.format = PA_SAMPLE_S16LE;
	ss.rate = actx->samplerate;
	ss.channels = actx->channels;

	/* Create a new playback stream */
	if (!(s = pa_simple_new (NULL, "despotify",
				 PA_STREAM_PLAYBACK,
				 NULL, "playback", &ss, NULL,
				 NULL, &error))) {
		DSFYDEBUG ("pa_simple_new() failed: %s\n",
			   pa_strerror (error));
		exit (-1);
	}

	priv = (void *) malloc (sizeof (pa_PRIVATE));
	assert (priv != NULL);

	if (pthread_mutex_init (&priv->lock, NULL) != 0) {
		perror ("pthread_mutex_init");
		exit (-1);
	}

	if (pthread_cond_init (&priv->pause, NULL) != 0) {
		perror ("pthread_cond_init");
		exit (-1);
	}

	if (pthread_cond_init (&priv->end, NULL) != 0) {
		perror ("pthread_cond_init");
		exit (-1);
	}

	priv->pa_simple = s;
	actx->driverprivate = (void *) priv;

	return 0;
}

int pulseaudio_pause (AUDIOCTX * actx)
{
	pa_PRIVATE *priv = (pa_PRIVATE *) actx->driverprivate;

	pthread_mutex_lock (&priv->lock);

	priv->state = PU_PAUSED;

	pthread_mutex_unlock (&priv->lock);

	return (0);
}

int pulseaudio_resume (AUDIOCTX * actx)
{

	pa_PRIVATE *priv = (pa_PRIVATE *) actx->driverprivate;

	pthread_mutex_lock (&priv->lock);

	priv->state = PU_PLAYING;

	/* Signal player thread */
	pthread_cond_signal (&priv->pause);
	pthread_mutex_unlock (&priv->lock);
	return (0);
}

int pulseaudio_play (AUDIOCTX * actx)
{
	int error;
	pa_simple *s;
	pa_PRIVATE *priv = (pa_PRIVATE *) actx->driverprivate;
	bool quit = false;

	assert (priv != NULL);

	s = (pa_simple *) priv->pa_simple;

	/* Driver loop */
	for (;;) {

		uint8_t buf[1024];
		ssize_t r;

		/* Fetch state lock */
		pthread_mutex_lock (&priv->lock);

		switch (priv->state) {
		case PU_END:
			quit = true;
			break;

		case PU_PAUSED:
			/* Wait for unpause signal */
			pthread_cond_wait (&priv->pause, &priv->lock);
			break;

		case PU_PLAYING:
		case PU_IDLE:
		default:
			break;
		}

		pthread_mutex_unlock (&priv->lock);

		if (quit)
			break;

		/* Read some data ... */
		r = pcm_read (actx->pcmprivate, (char *) buf, sizeof (buf), 0,
			      2, 1, NULL);

		if (r == OV_HOLE) {	/* vorbis got garbage */
			DSFYDEBUG ("pcm_read() == %s\n", "OV_HOLE");
			continue;
		}

		if (r <= 0) {
			if (r == 0)	/* EOF */
				break;
			DSFYDEBUG ("pcm_read() failed == %zd\n", r);
			exit (-1);
		}

		/* ... and play it */
		if (pa_simple_write (s, buf, (size_t) r, &error) < 0) {
			DSFYDEBUG ("pa_simple_write() failed: %s\n",
				   pa_strerror (error))
				exit (-1);
		}
	}

	/* Make sure that every single sample was played */
	if (pa_simple_drain (s, &error) < 0) {
		DSFYDEBUG ("pa_simple_drain() failed: %s\n",
			   pa_strerror (error))
			exit (-1);
	}

	if (s)
		pa_simple_free (s);

        pthread_cond_signal (&priv->end);

	/* This will kill the thread */
	return 0;
}

int pulseaudio_stop (AUDIOCTX * actx)
{
	pa_PRIVATE *priv = (pa_PRIVATE *) actx->driverprivate;

	assert (priv != NULL);

	/* Tell loop thread to exit */
	pthread_mutex_lock (&priv->lock);
	priv->state = PU_END;
        pthread_cond_wait (&priv->end, &priv->lock);
	pthread_mutex_unlock (&priv->lock);

        /* When the other loop has exited, free the non-audio
         * resources (memory, mutexes).
         */
        pthread_mutex_destroy (&priv->lock);
        pthread_cond_destroy (&priv->end);
        pthread_cond_destroy (&priv->pause);

        DSFYfree (actx->driverprivate);

	return 0;
}

int pulseaudio_free_device (void)
{

	/* N/A */

	return 0;
}

AUDIODRIVER pulseaudio_driver_desc = {
	pulseaudio_init_device,
	pulseaudio_free_device,

	pulseaudio_prepare_device,
	pulseaudio_play,
	pulseaudio_stop,
	pulseaudio_pause,
	pulseaudio_resume
}

, *driver = &pulseaudio_driver_desc;
