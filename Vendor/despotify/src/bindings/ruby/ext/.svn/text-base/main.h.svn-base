/*
 * $Id$
 */

#ifndef __RB_DESPOTIFY_H
#define __RB_DESPOTIFY_H

VALUE cSession;
VALUE cPlaylist;
VALUE cTrack;
VALUE cArtist;
VALUE cAlbum;

VALUE eDespotifyError;

typedef struct despotify_session despotify_session;
typedef struct playlist despotify_playlist;
typedef struct track despotify_track;
typedef struct artist despotify_artist;
typedef struct album despotify_album;
typedef struct user_info despotify_user_info;

#define BOOL2VALUE(exp) exp ? Qtrue : Qfalse


#define HASH_VALUE_ADD(hash, key, val) \
	rb_hash_aset(hash, rb_str_new2((key)), (val))


#define CHECKIDLEN(str, len) \
	if(strlen((str)) != len) \
		rb_raise (eDespotifyError, "expecting id length of %d", (len))

#define CHECKTYPE(obj, type) \
	if (rb_obj_is_instance_of ((obj), (type))) \
		rb_raise (rb_eTypeError, \
		          "wrong argument type %s (expected %s)", \
		           rb_obj_classname ((obj)), rb_obj_classname ((type)))

#endif
