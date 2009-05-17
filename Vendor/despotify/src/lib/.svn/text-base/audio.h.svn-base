/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_AUDIO_H
#define DESPOTIFY_AUDIO_H

/* Data needed for preparing the audio hardware for playback */
typedef struct
{
	float samplerate;
	int channels;
	char *title;
	int is_playing;
	int is_paused;
	void *pcmprivate;
	void *driverprivate;
} AUDIOCTX;

/* Audio driver description */
typedef struct
{
	/* For configuring the audio hardware */
	int (*register_hw) (void *);
	int (*unregister_hw) (void);

	/* Playback */
	int (*prepare) (AUDIOCTX *);
	int (*play) (AUDIOCTX *);
	int (*stop) (AUDIOCTX *);
	int (*pause) (AUDIOCTX *);
	int (*resume) (AUDIOCTX *);
} AUDIODRIVER;

int audio_init (void);
int audio_release (void);
int audio_play (AUDIOCTX *);
int audio_stop (AUDIOCTX *);
AUDIOCTX *audio_context_new (float, int, char *);
int audio_context_free (AUDIOCTX *);
int audio_pause (AUDIOCTX * a);
int audio_resume (AUDIOCTX * a);

/* Need to be exposed to audio.c, defined in coreaudio/pulseaudio/gstreamer.c */
extern AUDIODRIVER *driver;
#endif
