/*
 * $Id$
 */

#include <ruby.h>
#include <despotify.h>

#include "main.h"
#include "session.h"
#include "playlist.h"
#include "track.h"
#include "artist.h"
#include "album.h"


#define SESSION_METHOD_HEADER \
	rb_despotify_session *session; \
	VALUE2SESSION(self, session); \
	if (!session->connected) \
		rb_raise(eDespotifyError, "session is not connected");


static void
rb_despotify_session_free(rb_despotify_session *session) {
	if (session->rootpl)
		despotify_free_playlist(session->rootpl);

	if (session->real)
		despotify_exit(session->real);

	free(session);
}

static VALUE
rb_despotify_session_alloc(VALUE klass) {
	rb_despotify_session *session;

	VALUE obj = Data_Make_Struct(klass, rb_despotify_session, NULL,
	                             rb_despotify_session_free, session);

	return obj;
}


static VALUE
rb_despotify_session_new(VALUE self) {
	rb_despotify_session *session;
	VALUE2SESSION(self, session);

	if (!(session->real = despotify_init_client())) {
		rb_raise(rb_eNoMemError, "failed to allocate memory");
		return Qnil;
	}
	session->rootpl = NULL;
	session->connected = false;

	if (rb_block_given_p())
		rb_yield(self);

	return self;
}

static VALUE
rb_despotify_session_authenticate(VALUE self, VALUE username, VALUE password) {
	rb_despotify_session *session;
	VALUE2SESSION(self, session);

	if (!despotify_authenticate(session->real, StringValuePtr(username),
	                            StringValuePtr(password)))
		rb_raise(eDespotifyError, session->real->last_error);
	else
		session->connected = true;

	return self;
}

static VALUE
rb_despotify_session_search(VALUE self, VALUE searchtext) {
	SESSION_METHOD_HEADER
	despotify_playlist *pl;
	VALUE playlist;

	pl = despotify_search(session->real, StringValuePtr(searchtext));

	playlist = rb_despotify_playlist_new_from_pl(self, pl, false);

	if (rb_block_given_p())
		rb_yield(playlist);

	return playlist;
}

static VALUE
rb_despotify_session_playlists(VALUE self) {
	SESSION_METHOD_HEADER
	despotify_playlist *pl;
	VALUE playlists;

	playlists = rb_ary_new();

	if (!session->rootpl)
		session->rootpl = despotify_get_stored_playlists(session->real);

	if (!session->rootpl)
		return playlists;

	for (pl = session->rootpl; pl; pl = pl->next) {
		rb_ary_push(playlists, rb_despotify_playlist_new_from_pl(self, pl, true));
	}

	return playlists;
}

static VALUE
rb_despotify_session_get_image(VALUE self, VALUE image_id) {
	SESSION_METHOD_HEADER
	int len;
	void *data;
	char *id;

	id = StringValuePtr(image_id);
	data = despotify_get_image(session->real, id, &len);

	return rb_str_new((char *) data, len);
}

static VALUE
rb_despotify_session_play(VALUE self, VALUE playlist, VALUE track) {
	SESSION_METHOD_HEADER
	rb_despotify_playlist *pls;
	rb_despotify_track *t;

	VALUE2PLAYLIST(playlist, pls);
	VALUE2TRACK(track, t);

	return BOOL2VALUE(despotify_play(session->real, pls->real, t->real));
}

static VALUE
rb_despotify_session_user_info(VALUE self) {
	SESSION_METHOD_HEADER
	VALUE userinfo;
	despotify_user_info *info = NULL;

	info = session->real->user_info;
	userinfo = rb_hash_new();

	if (info) {
		HASH_VALUE_ADD(userinfo, "username", rb_str_new2(info->username));
		HASH_VALUE_ADD(userinfo, "country", rb_str_new2(info->country));
		HASH_VALUE_ADD(userinfo, "type", rb_str_new2(info->type));
		HASH_VALUE_ADD(userinfo, "expiry", INT2NUM(info->expiry));
		HASH_VALUE_ADD(userinfo, "server_host", rb_str_new2(info->server_host));
		HASH_VALUE_ADD(userinfo, "server_port", INT2NUM(info->server_port));
		HASH_VALUE_ADD(userinfo, "last_ping", INT2NUM(info->last_ping));
	}

	return userinfo;
}

static VALUE
rb_despotify_session_stop(VALUE self) {
	SESSION_METHOD_HEADER

	return BOOL2VALUE(despotify_stop(session->real));
}

static VALUE
rb_despotify_session_pause(VALUE self) {
	SESSION_METHOD_HEADER

	return BOOL2VALUE(despotify_pause(session->real));
}

static VALUE
rb_despotify_session_resume(VALUE self) {
	SESSION_METHOD_HEADER

	return BOOL2VALUE(despotify_resume(session->real));
}

static VALUE
rb_despotify_session_current_track(VALUE self) {
	SESSION_METHOD_HEADER

	return rb_despotify_track_new_from_track(despotify_get_current_track(session->real));
}

static VALUE
rb_despotify_session_get_error(VALUE self) {
	rb_despotify_session *session;
	VALUE2SESSION(self, session);

	if (session->real->last_error)
		return rb_str_new2(session->real->last_error);

	return Qnil;
}

static VALUE
rb_despotify_session_playlist(VALUE self, VALUE id) {
	VALUE args[2] = { self, id };

	return rb_class_new_instance (2, args, cPlaylist);
}

static VALUE
rb_despotify_session_artist(VALUE self, VALUE id) {
	VALUE args[2] = { self, id };

	return rb_class_new_instance (2, args, cArtist);
}

static VALUE
rb_despotify_session_album(VALUE self, VALUE id) {
	VALUE args[2] = { self, id };

	return rb_class_new_instance (2, args, cAlbum);
}


VALUE
Init_despotify_session(VALUE mDespotify) {
	VALUE c;

	/* Despotify::Session */
	c = rb_define_class_under(mDespotify, "Session", rb_cObject);
	rb_define_alloc_func (c, rb_despotify_session_alloc);
	rb_define_method(c, "initialize", rb_despotify_session_new, 0);
	rb_define_method(c, "authenticate", rb_despotify_session_authenticate, 2);
	rb_define_method(c, "search", rb_despotify_session_search, 1);
	rb_define_method(c, "playlists", rb_despotify_session_playlists, 0);
	rb_define_method(c, "get_image", rb_despotify_session_get_image, 1);
	rb_define_method(c, "get_error", rb_despotify_session_get_error, 0);
	rb_define_method(c, "user_info", rb_despotify_session_user_info, 0);

	rb_define_method(c, "play", rb_despotify_session_play, 2);
	rb_define_method(c, "stop", rb_despotify_session_stop, 0);
	rb_define_method(c, "pause", rb_despotify_session_pause, 0);
	rb_define_method(c, "resume", rb_despotify_session_resume, 0);
	rb_define_method(c, "current_track", rb_despotify_session_current_track, 0);

	/* Shortcuts */
	rb_define_method(c, "playlist", rb_despotify_session_playlist, 1);
	rb_define_method(c, "artist", rb_despotify_session_artist, 1);
	rb_define_method(c, "album", rb_despotify_session_album, 1);


	return c;
}
