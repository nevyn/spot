/*
 * $Id$
 */

#ifndef __RB_ALBUM_H
#define __RB_ALBUM_H

typedef struct {
	despotify_album *real;
	bool ischild;
} rb_despotify_album;

VALUE Init_despotify_album(VALUE mDespotify);
VALUE rb_despotify_album_new_from_album(despotify_album *a, bool ischild);

#define VALUE2ALBUM(obj, var) \
		Data_Get_Struct ((obj), rb_despotify_album, (var))

#endif
