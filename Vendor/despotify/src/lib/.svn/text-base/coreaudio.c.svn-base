/*
 * $Id$
 *
 * Mac OS X CoreAudio audio output driver for Despotify
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <CoreAudio/AudioHardware.h>

#include "audio.h"
#include "sndqueue.h"
#include "util.h"

static AudioDeviceID adev_id;
static AudioDeviceIOProcID adev_pid;

static OSStatus audio_callback (AudioDeviceID, const AudioTimeStamp *,
				const AudioBufferList *,
				const AudioTimeStamp *, AudioBufferList *,
				const AudioTimeStamp *, void *);

/*
 * Initialize and get an output device
 *
 */
int coreaudio_init_device (void *unused)
{
	OSStatus s;
	UInt32 sz;
	int value;

	sz = sizeof (adev_id);
	if ((s =
	     AudioHardwareGetProperty
	     (kAudioHardwarePropertyDefaultOutputDevice, &sz, &adev_id)))
		return -1;
	else if (adev_id == kAudioDeviceUnknown)
		return -1;

	value = 32 * 1024;
	sz = sizeof (value);
	if ((s =
	     AudioDeviceSetProperty (adev_id, 0, 0, false,
				     kAudioDevicePropertyBufferSize, sz,
				     &value)))
		return -1;

	return 0;
}

/*
 * Prepare for playback by configuring sample rate, channels, ..
 * We also set the callback routine CoreAudio will use to pull data
 * 
 */
int coreaudio_prepare_device (AUDIOCTX * actx)
{
	size_t sz;
	AudioStreamBasicDescription fmt;

	sz = sizeof (fmt);
	if (AudioDeviceGetProperty
			(adev_id, 0, false, kAudioDevicePropertyStreamFormat,
			 &sz, &fmt)) {
		DSFYDEBUG ("AudioDeviceGetProperty() failed\n");
		return -1;
	}
	fmt.mFormatID = kAudioFormatLinearPCM;
	fmt.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
	fmt.mSampleRate = actx->samplerate;
	fmt.mChannelsPerFrame = actx->channels;
	fmt.mFramesPerPacket = 1;
	fmt.mBytesPerFrame = fmt.mBytesPerPacket =
		sizeof (float) * fmt.mChannelsPerFrame;
	fmt.mReserved = 0;

	sz = sizeof (fmt);
	if (AudioDeviceSetProperty
			(adev_id, NULL, 0, false,
			 kAudioDevicePropertyStreamFormat, sz, &fmt)) {
		DSFYDEBUG ("AudioDeviceSetProperty() failed\n");
		return -1;
	}

	DSFYDEBUG ("kAudioDevicePropertyStreamFormat: mSampleRate %f\n",
		   fmt.mSampleRate);
	DSFYDEBUG
		("kAudioDevicePropertyStreamFormat: mFormatFlags 0x%08lx (IsSignedInteger:%s, isFloat:%s, isBigEndian:%s, kLinearPCMFormatFlagIsNonInterleaved:%s, kAudioFormatFlagIsPacked:%s)\n",
		 fmt.mFormatFlags,
		 fmt.mFormatFlags & kLinearPCMFormatFlagIsSignedInteger ?
		 "yes" : "no",
		 fmt.mFormatFlags & kLinearPCMFormatFlagIsFloat ? "yes" :
		 "no",
		 fmt.mFormatFlags & kLinearPCMFormatFlagIsBigEndian ? "yes" :
		 "no",
		 fmt.mFormatFlags & kLinearPCMFormatFlagIsNonInterleaved ?
		 "yes" : "no",
		 fmt.mFormatFlags & kAudioFormatFlagIsPacked ? "yes" : "no");

	DSFYDEBUG ("kAudioDevicePropertyStreamFormat: mBitsPerChannel %lu\n",
		   fmt.mBitsPerChannel);
	DSFYDEBUG
		("kAudioDevicePropertyStreamFormat: mChannelsPerFrame %lu\n",
		 fmt.mChannelsPerFrame);
	DSFYDEBUG ("kAudioDevicePropertyStreamFormat: mFramesPerPacket %lu\n",
		   fmt.mFramesPerPacket);
	DSFYDEBUG ("kAudioDevicePropertyStreamFormat: mBytesPerFrame %lu\n",
		   fmt.mBytesPerFrame);
	DSFYDEBUG ("kAudioDevicePropertyStreamFormat: mBytesPerPacket %lu\n",
		   fmt.mBytesPerPacket);

	if (AudioDeviceCreateIOProcID
			(adev_id, audio_callback, (void *) actx, &adev_pid)) {
		DSFYDEBUG ("AudioDeviceCreateIOProcID() returned FAIL!\n");

		return -1;
	}

	return 0;
}

int coreaudio_free_device (void)
{

	/* Deallocate callback routine and release output device here */
	DSFYDEBUG ("coreaudio_free_device(): Doing nothing\n");

	return 0;
}

int coreaudio_play (AUDIOCTX * actx)
{
	DSFYDEBUG ("coreaudio_play(): Calling AudioDeviceStart()!\n")

		if (AudioDeviceStart (adev_id, adev_pid)) {
		DSFYDEBUG ("coreaudio_play(): AudioDeviceStart() failed\n");
		return -1;
	}

	DSFYDEBUG ("coreaudio_play(): AudioDeviceStart() succeeded\n");

	return 0;
}

int coreaudio_stop (AUDIOCTX * actx)
{
	DSFYDEBUG ("coreaudio_stop(): Calling AudioDeviceStop()\n")
		if (AudioDeviceStop (adev_id, adev_pid)) {
		DSFYDEBUG ("coreaudio_stop(): AudioDeviceStop() failed\n");
		return -1;
	}

	DSFYDEBUG ("coreaudio_stop(): AudioDeviceStop() succeeded\n");

	return 0;
}

static OSStatus audio_callback (AudioDeviceID dev,
				const AudioTimeStamp * ts_now,
				const AudioBufferList * bufin,
				const AudioTimeStamp * ts_inputtime,
				AudioBufferList * bufout,
				const AudioTimeStamp * ts_outputtime,
				void *private)
{
	int ret;

	int i;
	short buf[16384];
	Float32 *dst = bufout->mBuffers[0].mData;
	int num_channels = 2;
	int samples_available =
		bufout->mBuffers[0].mDataByteSize / sizeof (float) /
		num_channels;
	int channel, sample;

	AUDIOCTX *actx = (AUDIOCTX *) private;

	DSFYDEBUG ("audio_callback()\n");

	/* Zero buffer */
	for (i = 0; i < samples_available * num_channels; i++)
		dst[i] = 0.0f;

	while (samples_available) {

		/* Read PCM data from Vorbis stream */
		if ((ret =
		     pcm_read (actx->pcmprivate, (char *) buf,
			       samples_available * sizeof (short) *
			       num_channels, 0, 2, 1, NULL)) <= 0) {

			DSFYDEBUG ("pcm_read(): got short count, error %d\n",
				   ret);
			break;

		}

		for (sample = 0; sample < ret / sizeof (short) / num_channels;
				sample++) {
			for (channel = 0; channel < num_channels; channel++) {
				if (buf[2 * sample + channel] <= 0)
					*dst++ = (float) (buf
							  [2 * sample +
							   channel]) /
						32767.0;
				else
					*dst++ = (float) (buf
							  [2 * sample +
							   channel]) /
						32768.0;
			}

			samples_available--;
		}
	}

	return ret;
}

AUDIODRIVER coreaudio_driver_desc = {
	coreaudio_init_device,
	coreaudio_free_device,

	coreaudio_prepare_device,
	coreaudio_play,		/* Play */
	coreaudio_stop,		/* Stop */
	coreaudio_stop,		/* Pause */
	coreaudio_play,		/* Resume */
}

, *driver = &coreaudio_driver_desc;
