/*
 *  audioqueue.h
 *  Spot
 *
 *  Created by Joachim Bengtsson on 2009-05-16.
 *  Copyright 2009 Third Cog Software. All rights reserved.
 *
 */

#ifndef DESPOTIFY_AUDIOQUEUE_H
#define DESPOTIFY_AUDIOQUEUE_H

#include "audio.h"

int audioqueue_init_device (void *);
int audioqueue_free_device (void *);
int audioqueue_prepare_device (AUDIOCTX *);
int audioqueue_play (AUDIOCTX *);
int audioqueue_stop (AUDIOCTX *);
#endif
