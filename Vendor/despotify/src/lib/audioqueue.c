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

int audioqueue_init_device (void *dev)
{
	return 0;
}
int audioqueue_free_device (void *dev)
{
	return 0;
}
int audioqueue_prepare_device (AUDIOCTX *ctx)
{
	return 0;
}
int audioqueue_play (AUDIOCTX *ctx)
{
	return 0;
}
int audioqueue_stop (AUDIOCTX *ctx)
{
	return 0;
}


AUDIODRIVER coreaudio_driver_desc = {
audioqueue_init_device,
audioqueue_free_device,

audioqueue_prepare_device,
audioqueue_play,		/* Play */
audioqueue_stop,		/* Stop */
audioqueue_stop,		/* Pause */
audioqueue_play,		/* Resume */
}

, *driver = &coreaudio_driver_desc;
