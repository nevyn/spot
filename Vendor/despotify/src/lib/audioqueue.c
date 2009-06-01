/*
 *  audioqueue.c
 *  Spot
 *
 *  Created by Joachim Bengtsson on 2009-05-16.
 *  Copyright 2009 Third Cog Software. All rights reserved.
 *
 */

#include "audioqueue.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "audio.h"
#include "sndqueue.h"
#include "util.h"

#include <AudioToolbox/AudioQueue.h>

#define kNumberBuffers 7
static struct AQPlayerState {
    AudioStreamBasicDescription   mDataFormat;
    AudioQueueRef                 mQueue;
    AudioQueueBufferRef           mBuffers[kNumberBuffers];
    volatile bool                          mIsRunning;
	AUDIOCTX *actx;
	unsigned bufferByteSize;
} state;

static void audio_callback (
 void *ignore,
 AudioQueueRef aq,
 AudioQueueBufferRef bufout
);

#include <CoreFoundation/CoreFoundation.h>
static char errstr[16];
void CAX4CCString(OSStatus error) {
	// see if it appears to be a 4-char-code
	char *str = errstr;
	*(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
	if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
		str[0] = str[5] = '\'';
		str[6] = '\0';
	} else if (error > -200000 && error < 200000)
		// no, format it as an integer
		sprintf(str, "%d", (int)error);
	else
		sprintf(str, "0x%x", (int)error);
}

#define check(x) do { \
	OSStatus __err = x; \
	if(__err != noErr) { \
		CAX4CCString(__err); \
		fprintf(stderr, "audioqueue driver error: %s\n", errstr);\
		return __err; \
	} \
} while(0)

void printFmt(AudioStreamBasicDescription fmt) {
	printf("kAudioDevicePropertyStreamFormat: mSampleRate %f\n",
			   fmt.mSampleRate);
	printf("kAudioDevicePropertyStreamFormat: mFormatFlags 0x%08lx "
		   "(IsSignedInteger:%s, isFloat:%s, isBigEndian:%s, "
		   "kLinearPCMFormatFlagIsNonInterleaved:%s, "
		   "kAudioFormatFlagIsPacked:%s)\n",
		   fmt.mFormatFlags,
		   fmt.mFormatFlags & kLinearPCMFormatFlagIsSignedInteger ? "yes":"no",
		   fmt.mFormatFlags & kLinearPCMFormatFlagIsFloat ? "yes" : "no",
		   fmt.mFormatFlags & kLinearPCMFormatFlagIsBigEndian ? "yes" : "no",
		   fmt.mFormatFlags & kLinearPCMFormatFlagIsNonInterleaved ? "yes":"no",
		   fmt.mFormatFlags & kAudioFormatFlagIsPacked ? "yes" : "no"
	);
	
	printf("kAudioDevicePropertyStreamFormat: mBitsPerChannel %lu\n",
		   fmt.mBitsPerChannel);
	printf("kAudioDevicePropertyStreamFormat: mChannelsPerFrame %lu\n",
		   fmt.mChannelsPerFrame);
	printf("kAudioDevicePropertyStreamFormat: mFramesPerPacket %lu\n",
			   fmt.mFramesPerPacket);
	printf("kAudioDevicePropertyStreamFormat: mBytesPerFrame %lu\n",
			   fmt.mBytesPerFrame);
	printf("kAudioDevicePropertyStreamFormat: mBytesPerPacket %lu\n",
			   fmt.mBytesPerPacket);	
}

int audioqueue_init_device (void *dev)
{
	printf("init device\n");
	memset(&state, 0, sizeof(state));
	return 0;
}
int audioqueue_free_device ()
{
	printf("free device\n");
	if( ! state.mQueue )
		return 0;
	
	audioqueue_stop(NULL);
	
	
	for (int i = 0; i < kNumberBuffers; ++i)
		AudioQueueFreeBuffer(state.mQueue, state.mBuffers[i]);
	
	check(AudioQueueDispose(state.mQueue, TRUE));
	state.mQueue = NULL;
	return 0;
}
int audioqueue_prepare_device (AUDIOCTX *actx)
{
	printf("preparing device\n");
	
	if(state.mQueue)
		return 0;
	
	AudioStreamBasicDescription *fmt = &state.mDataFormat;
	
	fmt->mFormatID = kAudioFormatLinearPCM;
	fmt->mFormatFlags = kAudioFormatFlagIsSignedInteger
					  | kAudioFormatFlagIsPacked;
	fmt->mSampleRate = actx->samplerate;
	fmt->mChannelsPerFrame = actx->channels;
	fmt->mFramesPerPacket = 1;
	fmt->mBytesPerFrame = sizeof (short) * fmt->mChannelsPerFrame;
	fmt->mBytesPerPacket = fmt->mBytesPerFrame;
	
	fmt->mBitsPerChannel = (fmt->mBytesPerFrame*8)/fmt->mChannelsPerFrame;
	fmt->mReserved = 0;
	
	state.actx = actx;	
	state.bufferByteSize = 32768;
	
	//printFmt(*fmt);
	
	check(AudioQueueNewOutput(
		fmt,
		audio_callback,
		NULL,
		NULL, //CFRunLoopGetCurrent(),
		NULL,
		0,
		&state.mQueue
	));
	
	
	
	return 0;
}


int audioqueue_play (AUDIOCTX *ctx)
{
	printf("playing device\n");
	state.mIsRunning = TRUE;
	
	if(!state.mBuffers[0])
		for (int i = 0; i < kNumberBuffers; ++i) {               
			check(AudioQueueAllocateBuffer (                           
											state.mQueue,             
											state.bufferByteSize,     
											&state.mBuffers[i]        
											));
			// Prime with data
			audio_callback (&state,                        
							state.mQueue,                  
							state.mBuffers[i]              
							);
			
		}		
	
	
	check(AudioQueueStart(state.mQueue, NULL));
	
	/*do {
		CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.25, false);
	} while (state.mIsRunning);*/
	
	
	return 0;
}

int audioqueue_stop (AUDIOCTX *ctx)
{
	printf("stopping device\n");
	state.mIsRunning = FALSE;
	check(AudioQueueStop(state.mQueue, TRUE));
  state.mQueue = NULL;
  state.mBuffers[0] = NULL;
  return 0;
}

int audioqueue_pause (AUDIOCTX *ctx)
{
	printf("pausing device\n");
	state.mIsRunning = FALSE;
	check(AudioQueuePause(state.mQueue));
  return 0;
}

static void audio_callback (
	void *ignore,
	AudioQueueRef aq,
	AudioQueueBufferRef bufout
) {
	if(!state.mIsRunning) return;
	
	int totalSamplesRead = 0;
	
	while (totalSamplesRead < state.bufferByteSize) {

		int samplesRead = pcm_read(
			state.actx->pcmprivate, // Audio context
			bufout->mAudioData + totalSamplesRead, // Buffer
			state.bufferByteSize - totalSamplesRead, // Bytes to read
			state.mDataFormat.mFormatFlags & kAudioFormatFlagIsBigEndian, // Big endian?
			state.mDataFormat.mBitsPerChannel/8, // Word size?
			TRUE, // Signed?
			NULL
		);
		
		if(samplesRead < 0) {
			fprintf(stderr, "pcm_read failed: %d", samplesRead);
			return;
		}
		
		totalSamplesRead += samplesRead;
	}

	bufout->mAudioDataByteSize = totalSamplesRead;
	AudioQueueEnqueueBuffer(state.mQueue, bufout, 0, NULL);
	return;
}


AUDIODRIVER coreaudio_driver_desc = {
audioqueue_init_device,
audioqueue_free_device,

audioqueue_prepare_device,
audioqueue_play,		/* Play */
audioqueue_stop,		/* Stop */
audioqueue_pause,		/* Pause */
audioqueue_play,		/* Resume */
}

, *driver = &coreaudio_driver_desc;
