/*
 * $Id$
 */

#ifndef __RB_ARTIST_H
#define __RB_ARTIST_H

typedef struct {
	despotify_artist *real;
} rb_despotify_artist;


VALUE Init_despotify_artist(VALUE mDespotify);
VALUE rb_despotify_artist_new_from_artist(despotify_artist *a);

#define VALUE2ARTIST(obj, var) \
	Data_Get_Struct ((obj), rb_despotify_artist, (var))

#endif
