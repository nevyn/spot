#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include <errno.h>
#include <stdint.h>

#include <gst/gst.h>

#include "gstapp/gstappsrc.h"
#include "gstapp/gstappbuffer.h"

#include "audio.h"
#include "sndqueue.h"
#include "gstreamer.h"
#include "util.h"

static gboolean bus_call (GstBus * bus, GstMessage * msg, gpointer user_data)
{
	(void) bus;
	(void) user_data;	/* don't warn. */
	switch (GST_MESSAGE_TYPE (msg)) {
	case GST_MESSAGE_EOS:
		{
			DSFYDEBUG ("End-of-stream\n");
			break;
		}
	case GST_MESSAGE_ERROR:
		{
			gchar *debug;
			GError *err;

			gst_message_parse_error (msg, &err, &debug);
			g_free (debug);

			DSFYDEBUG ("%s\n", err->message);
			g_error_free (err);

			break;
		}
	case GST_MESSAGE_INFO:
		{
			gchar *debug;
			GError *err;

			gst_message_parse_info (msg, &err, &debug);
			g_free (debug);

			DSFYDEBUG ("%s\n", err->message);
			g_error_free (err);

			break;
		}
	case GST_MESSAGE_WARNING:
		{
			gchar *debug;
			GError *err;

			gst_message_parse_warning (msg, &err, &debug);
			g_free (debug);

			DSFYDEBUG ("%s\n", err->message);
			g_error_free (err);

			break;
		}
	case GST_MESSAGE_STATE_CHANGED:
		{
			GstState new;
			GstState old;
			GstState pending;

			gst_message_parse_state_changed (msg, &new, &old,
							 &pending);
			DSFYDEBUG ("state changed (%d,%d,%d)\n", new, old,
				   pending);

			break;
		}
	default:
		DSFYDEBUG ("%s %d\n", __FUNCTION__, GST_MESSAGE_TYPE (msg));
		break;
	}

	return 1;
}

static void gstreamer_free_buffer (void *buffer)
{
	g_free (buffer);
}

static gboolean pause_cb (gpointer data)
{
	gst_PRIVATE *private = (gst_PRIVATE *) data;
	DSFYDEBUG ("%s\n", __FUNCTION__);
	gst_element_set_state (private->pipeline, GST_STATE_PAUSED);
	return FALSE;
}

static gboolean resume_cb (gpointer data)
{
	gst_PRIVATE *private = (gst_PRIVATE *) data;
	DSFYDEBUG ("%s\n", __FUNCTION__);
	gst_element_set_state (private->pipeline, GST_STATE_PLAYING);
	return FALSE;
}

static gboolean stop_cb (gpointer data)
{
	gst_PRIVATE *priv = (gst_PRIVATE *) data;

	/* Tell loop thread to exit */
	g_main_loop_quit (priv->loop);

	gst_element_set_state (priv->pipeline, GST_STATE_NULL);
	gst_object_unref (GST_OBJECT (priv->pipeline));

	free (priv);
	return FALSE;
}

static void need_data_cb (GstAppSrc * src, guint length, gpointer data)
{
	ssize_t r;
	uint8_t *buffer;
	GstBuffer *gstbuf;
	AUDIOCTX *actx = (AUDIOCTX *) data;

	if (length == 0 || length > 4096)
		length = 4096;

	buffer = g_new (uint8_t, length);
	while ((r =
		pcm_read (actx->pcmprivate, (char *) buffer, length, 0, 2, 1,
			  NULL)) == OV_HOLE)
		DSFYDEBUG ("pcm_read() == %s, retrying.\n", "OV_HOLE");

	if (r == 0) {
		gst_app_src_end_of_stream (GST_APP_SRC (src));
		return;
	}
	else if (r < 0) {
		DSFYDEBUG ("pcm_read() failed == %i\n", r);
		exit (-1);
	}

	gstbuf = gst_app_buffer_new (buffer, r, gstreamer_free_buffer, buffer);
	if (gst_app_src_push_buffer (GST_APP_SRC (src), gstbuf) !=
			GST_FLOW_OK)
        {
                (void)0; /* just to shut up the warn if not DEBUG. */
		DSFYDEBUG ("%s> call to push_buffer failed\n", __FUNCTION__);
        }
}

/*
 * Initialize and get an output device
 *
 */
int gstreamer_init_device (void *unused)
{
	(void) unused;		/* don't warn. */
	DSFYDEBUG ("%s\n", __FUNCTION__);
	gst_init (0, NULL);
	/* XXX: This needs to be changed. I think it'll crash and burn HORRIBLY 
	 * on a machine that has gstreamer-plugins-base-0.10 >= 0.10.22, since
	 * appsrc/gstapp is included as a part of that package.
	 */
	gst_element_register (NULL, "appsrc", GST_RANK_NONE,
			      GST_TYPE_APP_SRC);

	return 0;
}

/*
 * Prepare for playback by configuring sample rate, channels, ..
 * 
 */
int gstreamer_prepare_device (AUDIOCTX * actx)
{
	gst_PRIVATE *priv;
	GstElement *sink, *src;

	DSFYDEBUG ("%s channels %d samplerate %f\n", __FUNCTION__,
		   actx->channels, actx->samplerate);

	assert (actx->driverprivate == NULL);

	priv = (void *) malloc (sizeof (gst_PRIVATE));
	assert (priv != NULL);

	/* create a new gmainloop */
	priv->loop = g_main_loop_new (NULL, FALSE);

	/* create a new gstreamer pipeline */
	priv->pipeline = gst_pipeline_new (NULL);
	g_assert (priv->pipeline);

	/* create a gstreamer AppSrc, capab values taken from pulseaudio backend. */
	src = gst_element_factory_make ("appsrc", NULL);
	g_assert (src);
	gst_app_src_set_stream_type (GST_APP_SRC (src),
				     GST_APP_STREAM_TYPE_STREAM);
	gst_app_src_set_caps (GST_APP_SRC (src),
			      gst_caps_new_simple ("audio/x-raw-int",
						   "channels", G_TYPE_INT,
						   actx->channels, "rate",
						   G_TYPE_INT,
						   (int) actx->samplerate,
						   "signed", G_TYPE_BOOLEAN,
						   TRUE, "endianness",
						   G_TYPE_INT,
						   G_LITTLE_ENDIAN, "width",
						   G_TYPE_INT, 16, "depth",
						   G_TYPE_INT, 16, NULL)
		);
	g_object_set (src, "format", GST_FORMAT_TIME, NULL);
	g_signal_connect (src, "need-data", G_CALLBACK (need_data_cb), actx);
	gst_bin_add (GST_BIN (priv->pipeline), src);

	sink = gst_element_factory_make ("autoaudiosink", NULL);
	g_assert (sink);
	gst_bin_add (GST_BIN (priv->pipeline), sink);

	if (!gst_element_link (src, sink)) {
		fprintf (stderr, "failed to link gstreamer elements");
		exit (-1);
	}

	GstBus *bus;
	bus = gst_pipeline_get_bus (GST_PIPELINE (priv->pipeline));
	gst_bus_add_watch (bus, bus_call, NULL);
	gst_object_unref (bus);

	actx->driverprivate = (void *) priv;
	return 0;
}

int gstreamer_pause (AUDIOCTX * actx)
{
	DSFYDEBUG ("%s\n", __FUNCTION__);
	g_idle_add (pause_cb, actx->driverprivate);
	return 0;
}

int gstreamer_resume (AUDIOCTX * actx)
{
	DSFYDEBUG ("%s\n", __FUNCTION__);
	g_idle_add (resume_cb, actx->driverprivate);
	return 0;
}

int gstreamer_play (AUDIOCTX * actx)
{
	gst_PRIVATE *priv = (gst_PRIVATE *) actx->driverprivate;
	assert (priv != NULL);

	DSFYDEBUG ("%s\n", __FUNCTION__);

	gst_element_set_state (GST_ELEMENT (priv->pipeline),
			       GST_STATE_PLAYING);
	g_main_loop_run (priv->loop);

	/* This will kill the thread */
	return 0;
}

int gstreamer_stop (AUDIOCTX * actx)
{
	gst_PRIVATE *priv = (gst_PRIVATE *) actx->driverprivate;
	assert (priv != NULL);

	DSFYDEBUG ("%s\n", __FUNCTION__);

	g_idle_add (stop_cb, priv);
	actx->driverprivate = NULL;

	return 0;
}

int gstreamer_free_device (void)
{
	DSFYDEBUG ("%s\n", __FUNCTION__);
	return 0;
}

AUDIODRIVER gstreamer_driver_desc = {
	gstreamer_init_device,
	gstreamer_free_device,

	gstreamer_prepare_device,
	gstreamer_play,
	gstreamer_stop,
	gstreamer_pause,
	gstreamer_resume
}

, *driver = &gstreamer_driver_desc;
