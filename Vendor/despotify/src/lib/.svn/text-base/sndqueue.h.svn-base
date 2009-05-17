/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_SNDQUEUE_H
#define DESPOTIFY_SNDQUEUE_H

#include <pthread.h>
#include <vorbis/vorbisfile.h>

#include "audio.h"

/* Default buffer treshold value is 80 % */
#define BUFFER_THRESHOLD 80;

enum
{
	SND_CMD_INIT = 0,
	SND_CMD_DATA = 1,
	SND_CMD_END = 2
};

enum
{
	DL_IDLE = 0,
	DL_DOWNLOADING = 1,
	DL_END = 2
};

typedef struct oggBUFF
{

	/* Total length of this buffer */
	int length;

	/* command for the player... 1 == DATA, 0 == INIT */
	int cmd;

	/* Number of bytes consumed */
	int consumed;

	struct oggBUFF *next;
	unsigned char data[1];
} oggBUFF;

typedef struct oggFIFO
{
	pthread_mutex_t lock;

	/* Signal reciever that there is something in the queue */
	pthread_cond_t cs;

	/* Total number of bytes added to queue */
	int totbytes;

	struct oggBUFF *start;	/* Start of queue */
	struct oggBUFF *end;	/* End of queue */

} oggFIFO;

struct snd_session;

typedef int (*audio_request_callback) (void *);
typedef void (*time_tell_callback) (struct snd_session *, int cur_time);

typedef struct snd_session
{
	pthread_t thr_id;
	pthread_mutex_t lock;

	int dlstate;

	/* FIFO */
	struct oggFIFO *fifo;

	/* Current Ogg Vorbis info and playback context */
	OggVorbis_File *vf;

	AUDIOCTX *actx;

	/* How much of the buffer to consume before requesting more data */
	int buffer_threshold;

	/* Callback when more data is needed */
	audio_request_callback audio_request;

	/* Callback when ogg data ends */
	audio_request_callback audio_end;

	/* Arguments */
	void *audio_request_arg;
	void *audio_end_arg;

	/* time tell callback */
        time_tell_callback time_tell;

} snd_SESSION;

void snd_reset (snd_SESSION * session);
snd_SESSION *snd_init (void);
void snd_destroy (snd_SESSION *);
void snd_set_data_callback (snd_SESSION *, audio_request_callback, void *);
void snd_set_end_callback (snd_SESSION * session,
			   audio_request_callback callback, void *arg);
void snd_set_timetell_callback (snd_SESSION * session,
                                time_tell_callback callback);

int snd_stop (void *);
void snd_start (snd_SESSION * session);
void snd_ioctl (struct snd_session *session, int cmd, void *data, int length);
long pcm_read (void *private, char *buffer, int length, int bigendianp,
	       int word, int sgned, int *bitstream);

void snd_mark_dlding (snd_SESSION * session);
void snd_mark_idle (snd_SESSION * session);
void snd_mark_end (snd_SESSION * session);
#endif
