/*
 * $Id$
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <assert.h>

#include "sndqueue.h"
#include "util.h"

/* mainloop */
static void *snd_thread (void *);
static size_t snd_read_and_dequeue_callback (void *ptr, size_t size,
					     size_t nmemb, void *private);

/* Reset for new song */
void snd_reset (snd_SESSION * session)
{
	DSFYDEBUG ("snd_reset(): Setting state to DL_IDLE\n");
	session->fifo->totbytes = 0;
	session->dlstate = DL_IDLE;
	session->buffer_threshold = BUFFER_THRESHOLD;
}

/* Initialize sound session, called once */
snd_SESSION *snd_init (void)
{
	snd_SESSION *session;

	DSFYDEBUG ("snd_init(): Entering..\n");

	/* Init session struct */
	session = (snd_SESSION *) malloc (sizeof (snd_SESSION));
	if (!session)
		return NULL;

	session->vf = NULL;
	session->actx = NULL;
	session->dlstate = DL_IDLE;
	session->audio_request = NULL;
	session->audio_request_arg = NULL;
	session->buffer_threshold = BUFFER_THRESHOLD;
	session->audio_end = snd_stop;	/* Default is to stop the snd thread */
	session->time_tell = NULL;
	if (pthread_mutex_init (&session->lock, NULL)) {
		DSFYfree (session);

		return NULL;
	}

	/* This is the queue that will hold fragments of compressed audio */
	session->fifo = (oggFIFO *) malloc (sizeof (oggFIFO));
	if (!session->fifo) {
		pthread_mutex_destroy (&session->lock);
		DSFYfree (session);

		return NULL;
	}

	session->fifo->totbytes = 0;
	session->fifo->start = NULL;
	session->fifo->end = NULL;

	if (pthread_mutex_init (&session->fifo->lock, NULL)) {
		DSFYfree (session->fifo);

		pthread_mutex_destroy (&session->lock);
		DSFYfree (session);

		return NULL;
	}

	if (pthread_cond_init (&session->fifo->cs, NULL) != 0) {
		pthread_mutex_destroy (&session->fifo->lock);
		DSFYfree (session->fifo);

		pthread_mutex_destroy (&session->lock);
		DSFYfree (session);

		return NULL;
	}

	return session;
}

/* Destroy a sound session */
void snd_destroy (snd_SESSION * session)
{
	int ret = 0;
	oggBUFF *b;

	/* This will stop any playing sound too */
	if (session->actx)
		ret = audio_context_free (session->actx);

	/* Free the FIFO */
	if (session->fifo) {
		pthread_mutex_lock(&session->fifo->lock); /*rKA*/

		/* free oggBuffs */
		while (session->fifo->start) {
			b = session->fifo->start;
			session->fifo->start = session->fifo->start->next;
			DSFYfree (b);
		}

		pthread_mutex_unlock(&session->fifo->lock); /*rKA*/
		DSFYfree (session->fifo);

		pthread_cond_destroy (&session->fifo->cs);
		pthread_mutex_destroy (&session->fifo->lock);

	}

	pthread_mutex_destroy (&session->lock);
	DSFYfree (session);

}

/*
 * Set callback to be used to request more sound data
 * Called directly after snd_start() and when buffer runs
 * out of data
 *
 */
void snd_set_data_callback (snd_SESSION * session,
			    audio_request_callback callback, void *arg)
{
	session->audio_request = callback;
	session->audio_request_arg = arg;
}

/*
 * Set callback to be called when song finishes.
 */
void snd_set_end_callback (snd_SESSION * session,
			   audio_request_callback callback, void *arg)
{
	session->audio_end = callback;
	session->audio_end_arg = arg;


}

/*
 * Set callback to be called when time updates.
 */
void snd_set_timetell_callback (snd_SESSION * session,
				time_tell_callback callback)
{
  session->time_tell = callback;
}

/* Wrapper for ov_read() */
long pcm_read (void *private, char *buffer, int length, int bigendianp,
	       int word, int sgned, int *bitstream)
{
	snd_SESSION *session = (snd_SESSION *) private;

	if (session->time_tell != NULL) {
		DSFYDEBUG_SNDQUEUE ("pcm_read(): Entering time_tell callback at %p\n",
			   session->time_tell);
		session->time_tell (session,
				    (int) ov_time_tell (session->vf));
	}

	/* Make sure we've always got 10 seconds of data buffered */
	if ((session->dlstate != DL_END) &&
			session->fifo->totbytes <
			ov_raw_tell (session->vf) + 10 * 160 * 1024 / 8) {

		DSFYDEBUG_SNDQUEUE
			("pcm_read(): Locking session->fifo since we're low on data (FIFO total %.3fkB, vorbis offset %.3fkB, want %.3fkB)\n",
			 session->fifo->totbytes / 1024.0,
			 ov_raw_tell (session->vf) / 1024.0,
			 ((int) ov_raw_tell (session->vf) +
			  10 * 160 * 1024 / 8 -
			  session->fifo->totbytes) / 1024.0);
		pthread_mutex_lock (&session->lock);

		/* threshold level of the available buffer has been consumed, request more data */
		if (session->audio_request != NULL
				&& session->dlstate == DL_IDLE) {

			/* Call audio request function */
			DSFYDEBUG
				("pcm_read(): Low on data, calling session->audio_request(session=%p)\n",
				 session->audio_request_arg);

			session->audio_request (session->audio_request_arg);

			/* We can't call snd_mark_dlding() because it requires the lock to not be held so we do it inline */
			DSFYDEBUG
				("pcm_read(): audio_request() has been called, setting snd state to DL_DOWNLOADING\n");
			session->dlstate = DL_DOWNLOADING;

#ifdef X_TEST
			/* Hopefully the audio_request() callback is fetching more data for us now */
			snd_mark_dlding (session);
#endif
		}

		DSFYDEBUG_SNDQUEUE
			("pcm_read(): Unlocking session->fifo after being low on data\n");
		pthread_mutex_unlock (&session->lock);
	}

	DSFYDEBUG_SNDQUEUE
		("pcm_read(): Calling ov_read(len=%d), totbytes=%d, ov_raw_tell=%lld\n",
		 length, session->fifo->totbytes, ov_raw_tell (session->vf));
	return (ov_read
		(session->vf, buffer, length, bigendianp, word, sgned,
		 bitstream));
}

/* This function stops the player thread */
int snd_stop (void *arg)
{
	snd_SESSION *session = (snd_SESSION *) arg;
	oggBUFF *b;
	int ret;

        if (!arg)
        {
            DSFYDEBUG ("%s: Got NULL session, ignoring call.\n", __FUNCTION__);
            return 0;
        }

	DSFYDEBUG ("%s: Entering with arg %p\n", __FUNCTION__, arg);
	DSFYDEBUG ("%s: audio context is %p, dl state is %d\n", __FUNCTION__,
		   session->actx, session->dlstate);

	/* Stop the audio thread */
	if (session->actx)
		ret = audio_stop (session->actx);

	/* Empty the ogg-buffer if there is anything left */
	while (session->fifo->start) {
		b = session->fifo->start;
		session->fifo->start = session->fifo->start->next;
		DSFYfree (b);
	}

	session->fifo->start = NULL;
	session->fifo->end = NULL;

	/* Reset the session */
	snd_reset (session);

	return ret;
}

/* We are currently adding stuff to the queue */
void snd_mark_dlding (snd_SESSION * session)
{

#ifndef X_TEST
	pthread_mutex_lock (&session->lock);
#endif

	DSFYDEBUG ("snd_mark_dlding(): Setting state to DL_DOWNLOADING\n");
	session->dlstate = DL_DOWNLOADING;

#ifndef X_TEST
	pthread_mutex_unlock (&session->lock);
#endif
}

/* We have finished adding stuff to the queue */
void snd_mark_idle (snd_SESSION * session)
{
	pthread_mutex_lock (&session->lock);
	DSFYDEBUG ("snd_mark_idle(): Setting state to DL_IDLE\n");
	session->dlstate = DL_IDLE;
	pthread_mutex_unlock (&session->lock);
}

/* Tell soundlayer that the song has finished */
void snd_mark_end (snd_SESSION * session)
{
	pthread_mutex_lock (&session->lock);
	DSFYDEBUG ("snd_mark_end(): Setting state to DL_END\n");
	session->dlstate = DL_END;
	pthread_mutex_unlock (&session->lock);
}

void snd_ioctl (snd_SESSION * session, int cmd, void *data, int length)
{
	oggBUFF *buff;

	buff = (oggBUFF *) malloc (sizeof (oggBUFF) + length);

	if (buff == NULL) {
		perror ("malloc failed");
		exit (-1);
	}

	buff->next = NULL;
	buff->cmd = cmd;
	buff->length = 0;
	buff->consumed = 0;

	if (length > 0) {
		/* Copy data into buffer */
		memcpy (buff->data, data, length);

		buff->length = length;
	}

	pthread_mutex_lock (&session->fifo->lock);

	/* Hook in entry in linked list */
	if (session->fifo->end != NULL) {
		session->fifo->end->next = buff;
	}

	session->fifo->end = buff;

	/* If this is the first entry */
	if (session->fifo->start == NULL)
		session->fifo->start = buff;

	session->fifo->totbytes += length;

	DSFYDEBUG_SNDQUEUE
		("snd_ioctl(): added a new buffer with %d bytes data, signalling receiver\n",
		 length);
	pthread_mutex_unlock (&session->fifo->lock);

	/* Signal receiver */
	pthread_cond_signal (&session->fifo->cs);
}

/*
 * Ogg-Vorbis read() callback, used by snd_thread()
 * Called by both ov_info() and ov_read()
 * 
 * This functions dequeues items from the fifo
 *
 * This function is first called from snd_thread when ov_open_callbacks() 
 * is called in order to init the ogg-layer. Then its up to the called from
 * whatever thread is used to acced pcm_read(). On mac os x this is the 
 * coreaudio-thread.
 *
 */
static size_t snd_read_and_dequeue_callback (void *ptr, size_t size,
					     size_t nmemb, void *private)
{
	snd_SESSION *session = (snd_SESSION *) private;
	oggBUFF *b;
	size_t length;
	int ptrsize = size * nmemb;
	int remaining;

	pthread_mutex_lock (&session->fifo->lock);

	/* Check queue status */
	if (session->fifo->start == NULL) {
		/* There is no data in the queue .. */

		DSFYDEBUG
			("snd_read_and_dequeue_callback(): There is no data in the queue, requesting session->lock!\n");
		pthread_mutex_lock (&session->lock);

		if (session->audio_request != NULL &&
				session->dlstate == DL_IDLE) {
			/* Request more data */

			DSFYDEBUG
				("snd_read_and_dequeue_callback(): In DL_IDLE, calling session->audio_request(arg=%p)\n",
				 session->audio_request_arg);
			session->audio_request (session->audio_request_arg);
			DSFYDEBUG
				("snd_read_and_dequeue_callback(): Returned from ->audio_request()\n");
		}

		pthread_mutex_unlock (&session->lock);

		/* pthread_cond_wait will lock the queue again as soon as we are signaled */
		DSFYDEBUG
			("snd_read_and_dequeue_callback(): waiting for more data..\n");
		pthread_cond_wait (&session->fifo->cs, &session->fifo->lock);
		DSFYDEBUG
			("snd_read_and_dequeue_callback(): got signal about more data!\n");
	}

	/* We have data .. process one buffer */
	b = session->fifo->start;

	/* Check if this is the last pkt */
	if (b->cmd == SND_CMD_END) {
		/* Call end callback and return 0 */
		DSFYDEBUG
			("snd_read_and_dequeue_callback(): Got SND_CMD_END\n");

		/* Increment by one */
		session->fifo->start = session->fifo->start->next;

		/* If this was the last entry */
		if (b == session->fifo->end)
			session->fifo->end = NULL;

		DSFYfree (b);

		DSFYDEBUG
			("snd_read_and_dequeue_callback(): Releasing session->fifo->lock at end of song\n");
		pthread_mutex_unlock (&session->fifo->lock);

		DSFYDEBUG
			("snd_read_and_dequeue_callback(): calling ->audio_end at %p with arg %p (default snd_stop==%p)\n",
			 session->audio_end, session->audio_end_arg,
			 snd_stop);
		if (session->audio_end != NULL) {
			return session->audio_end (session->audio_end_arg);
		}

		return 0;
	}

	remaining = b->length - b->consumed;

	if (remaining < ptrsize)
		length = remaining;	/* The entire buffer will fitt */
	else
		length = ptrsize;	/* dont overrun ptrsize */

	memcpy (ptr, &b->data[b->consumed], length);

	b->consumed += length;

	/* If we have used the entire buffer we unlink it */
	if (b->consumed == b->length) {

		session->fifo->start = session->fifo->start->next;

		/* If this was the last entry */
		if (b == session->fifo->end)
			session->fifo->end = NULL;

		DSFYfree (b);
	}

	pthread_mutex_unlock (&session->fifo->lock);

	/* Return number of bytes read to ogg-layer */
	/* If the ogg-layer needs more data it will call us again */
	return length;
}

/* 
 * This function needs its own thread so that it can block while there is 
 * no data in the queue. Once ov_open_callbacks() has completed this function
 * will leave audio processing to the appropriate OS-depended audio processing 
 * function. In the case of mac os x this is done in its own thread and this 
 * thread therefore dies after calling audio_play(). 
 *
 * For Linux the player will run in this thread.
 *
 * 
 */

/* Start the thread */
void snd_start (snd_SESSION * session)
{
	pthread_attr_t atr;

	DSFYDEBUG ("snd_start(): Creating sound thread..\n");

	pthread_attr_init (&atr);
	pthread_attr_setdetachstate (&atr, PTHREAD_CREATE_DETACHED);

	if (pthread_create
			(&session->thr_id, &atr, snd_thread,
			 (void *) session) != 0) {
		perror ("pthread_create");
		exit (-1);
	}

	DSFYDEBUG ("snd_start(): leaving..\n");
}

static void *snd_thread (void *arg)
{
	snd_SESSION *s = (snd_SESSION *) arg;
	ov_callbacks snd_vorbisfile_callbacks;
	vorbis_info *vi;
	int ret;

	DSFYDEBUG ("snd_thread(): enter..\n");

	/* Allocate Vorbis struct */
	if ((s->vf = malloc (sizeof (OggVorbis_File))) == NULL)
		exit (-1);

	/* Initialize Vorbis struct with the appropriate callbacks */
	snd_vorbisfile_callbacks.read_func = snd_read_and_dequeue_callback;
	snd_vorbisfile_callbacks.seek_func = NULL;
	snd_vorbisfile_callbacks.close_func = NULL;
	snd_vorbisfile_callbacks.tell_func = NULL;

	/* Now call ov_open_callbacks(). This will trigger the read callback */
	DSFYDEBUG ("snd_thread(): Calling ov_open_callbacks()..\n");

	if ((ret =
	     ov_open_callbacks (s, s->vf, NULL, 0,
				snd_vorbisfile_callbacks))) {
		DSFYDEBUG
			("snd_thread(): ov_open_callbacks() said %d (OV_ENOTVORBIS=%d)\n",
			 ret, OV_ENOTVORBIS)
			return NULL;
	}

	DSFYDEBUG ("snd_thread(): Returned from ov_open_callbacks()..\n");

	/* The ov_open_callbacks() read enough data for ov_info() .. */
	vi = ov_info (s->vf, -1);

	/* Prepare the audio output device for playing by telling it the samplerate and # of channels */
	DSFYDEBUG
		("snd_thread(): calling audio_context_new(%ld, vi->channels, NULL)\n",
		 vi->rate)
		if ((s->actx =
		     audio_context_new ((float) vi->rate, vi->channels,
					NULL)) == NULL) {
		DSFYDEBUG
			("snd_thread(): audio_context_new() failed, exiting sound thread..\n");
		return NULL;
	}

	/* Make sure pcm_read has access to session -- fulhakk++ adio_callback borde fa hela session-structen */
	s->actx->pcmprivate = s;
	DSFYDEBUG ("s->actx->pcmprivate set to %p, s->actx is %p\n",
		   s->actx->pcmprivate, s->actx);

	/* On Macosx this function will return, on Linux it will not */
	DSFYDEBUG
		("snd_thread(): calling audio_play() on the audio context\n");
	audio_play (s->actx);

	/* Exit this thread */
	DSFYDEBUG
		("snd_thread(): audio_play() returned, exiting sound thread..\n");

	return NULL;
}
