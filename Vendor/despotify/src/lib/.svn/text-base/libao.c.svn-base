/*
 * $Id$
 *
 * Libao audio output driver for Despotify
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

#include <ao/ao.h>

#include "audio.h"
#include "sndqueue.h"
#include "libao.h"
#include "util.h"

/*
 * Initialize libao
 *
 */
int libao_init_device (void *unused)
{
	(void) unused;		/* don't warn */
	ao_initialize ();

	return 0;
}

/*
 * Prepare for playback by configuring sample rate, channels, ..
 *
 */
int libao_prepare_device (AUDIOCTX * actx)
{
	ao_device *device;
	ao_sample_format format;
	int default_driver;
	ao_PRIVATE *priv;

	default_driver = ao_default_driver_id ();

	format.bits = 16;
	format.rate = actx->samplerate;
	format.channels = actx->channels;
	format.byte_format = AO_FMT_LITTLE;

	device = ao_open_live (default_driver, &format, NULL);
	if (device == NULL) {
		DSFYDEBUG ("ao_open_live() failed\n");
		exit (-1);
	}

	priv = (void *) malloc (sizeof (ao_PRIVATE));
	assert (priv != NULL);

	if (pthread_mutex_init (&priv->lock, NULL) != 0) {
		perror ("pthread_mutex_init");
		exit (-1);
	}

	if (pthread_cond_init (&priv->pause, NULL) != 0) {
		perror ("pthread_cond_init");
		exit (-1);
	}

	priv->device = device;
	actx->driverprivate = (void *) priv;

	return 0;
}

int libao_pause (AUDIOCTX * actx)
{
	ao_PRIVATE *priv = (ao_PRIVATE *) actx->driverprivate;

	pthread_mutex_lock (&priv->lock);

	priv->state = AO_PAUSED;

	pthread_mutex_unlock (&priv->lock);

	return 0;
}

int libao_resume (AUDIOCTX * actx)
{

	ao_PRIVATE *priv = (ao_PRIVATE *) actx->driverprivate;

	pthread_mutex_lock (&priv->lock);

	priv->state = AO_PLAYING;

	/* Signal player thread */
	pthread_cond_signal (&priv->pause);
	pthread_mutex_unlock (&priv->lock);

	return 0;
}

int libao_play (AUDIOCTX * actx)
{
	ao_device *device;
	ao_PRIVATE *priv = (ao_PRIVATE *) actx->driverprivate;
	bool quit = false;

	assert (priv != NULL);

	device = (ao_device *) priv->device;

	/* Driver loop */
	for (;;) {
		unsigned char buf[8192];
		ssize_t r;

		/* Fetch state lock */
		pthread_mutex_lock (&priv->lock);

		switch (priv->state) {
		case AO_END:
			quit = true;
			break;

		case AO_PAUSED:
			/* Wait for unpause signal */
			pthread_cond_wait (&priv->pause, &priv->lock);
			break;

		case AO_PLAYING:
		case AO_IDLE:
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
			DSFYDEBUG ("pcm_read() == OV_HOLE\n");
			continue;
		}

		if (r <= 0) {
			DSFYDEBUG ("pcm_read() == %zd\n", r);
			if (r == 0)	/* EOF */
				break;
			exit (-1);
		}

		/* ... and play it */
		if (ao_play (device, (char *) buf, (int) r) == 0) {
			DSFYDEBUG ("ao_play() failed\n");
			exit (-1);
		}
	}

	if (ao_close (device) == 0) {
		DSFYDEBUG ("ao_close() failed\n");
		exit (-1);
	}

        pthread_mutex_destroy (&priv->lock);
        pthread_cond_destroy (&priv->pause);

        DSFYfree(actx->driverprivate);
	/* This will kill the thread */
	DSFYDEBUG ("libao thread exiting\n");
	return 0;
}

int libao_stop (AUDIOCTX * actx)
{
	ao_PRIVATE *priv = (ao_PRIVATE *) actx->driverprivate;

	assert (priv != NULL);

	/* Tell loop to exit */
	pthread_mutex_lock (&priv->lock);
	priv->state = AO_END;
	pthread_mutex_unlock (&priv->lock);

	return 0;
}

int libao_free_device (void)
{

	ao_shutdown ();

	return 0;
}

AUDIODRIVER libao_driver_desc = {
	libao_init_device,
	libao_free_device,

	libao_prepare_device,
	libao_play,
	libao_stop,
	libao_pause,
	libao_resume
}

, *driver = &libao_driver_desc;
