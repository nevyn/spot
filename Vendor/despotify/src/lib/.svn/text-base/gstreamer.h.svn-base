
#ifndef DESPOTIFY_GSTREAMER_H
#define DESPOTIFY_GSTREAMER_H

#include <gst/gst.h>

#include "audio.h"

typedef struct gst_private
{
	GstElement *pipeline;
	GMainLoop *loop;
} gst_PRIVATE;

int gstreamer_init_device (void *);
int gstreamer_free_device (void);
int gstreamer_prepare_device (AUDIOCTX *);
int gstreamer_play (AUDIOCTX *);
int gstreamer_stop (AUDIOCTX *);
#endif
