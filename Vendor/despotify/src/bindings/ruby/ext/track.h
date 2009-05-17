/*
 * $Id: track.h 266 2009-03-27 02:36:26Z chripppa $
 */

#ifndef __RB_TRACK_H
#define __RB_TRACK_H

typedef struct {
		despotify_track *real;
} rb_despotify_track;

VALUE Init_despotify_track(VALUE mDespotify);
VALUE rb_despotify_track_new_from_track(despotify_track *t);

#define VALUE2TRACK(obj, var) \
		Data_Get_Struct ((obj), rb_despotify_track, (var))

#endif
