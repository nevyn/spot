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

#define PLAYLIST_METHOD_HEADER \
	rb_despotify_playlist *pls; \
	VALUE2PLAYLIST(self, pls);


static void
rb_despotify_playlist_free(rb_despotify_playlist *pl) {
	if (!pl->ischild)
		despotify_free_playlist(pl->real);

	free(pl);
}

static VALUE
rb_despotify_playlist_alloc(VALUE klass) {
	rb_despotify_playlist *pls;

	VALUE obj = Data_Make_Struct(klass, rb_despotify_playlist, NULL,
	                             rb_despotify_playlist_free, pls);

	return obj;
}

VALUE
rb_despotify_playlist_new_from_pl(VALUE session, despotify_playlist *pl, bool ischild) {
	VALUE obj;
	rb_despotify_playlist *pls;

	if (!pl)
		return Qnil;

	obj = rb_despotify_playlist_alloc(cPlaylist);
	VALUE2PLAYLIST(obj, pls);

	pls->real = pl;
	pls->ischild = ischild;

	rb_iv_set(obj, "session", session);

	return obj;
}

static VALUE
rb_despotify_playlist_new(VALUE self, VALUE session, VALUE id) {
	rb_despotify_session *sessionptr;
	rb_despotify_playlist *pls;

	despotify_playlist *pl;
	char *playlist_id;

	VALUE2PLAYLIST(self, pls);
	VALUE2SESSION(session, sessionptr);
	playlist_id = StringValuePtr(id);

	CHECKIDLEN(playlist_id, 34);

	pl = (despotify_playlist *) despotify_get_playlist(sessionptr->real, playlist_id);
	if(!pl)
		return Qnil;

	pls->real = pl;
	pls->ischild = false;

	rb_iv_set(self, "session", session);

	if (rb_block_given_p())
		rb_yield(self);

	return self;
}


static VALUE
rb_despotify_playlist_tracks(VALUE self) {
	PLAYLIST_METHOD_HEADER

	if (rb_iv_get(self, "tracks") == Qnil) {
		VALUE tracks;
		despotify_track *t;

		tracks = rb_ary_new();

		for(t = pls->real->tracks; t; t = t->next) {
			rb_ary_push(tracks, rb_despotify_track_new_from_track(t));
		}

		rb_iv_set(self, "tracks", tracks);
	}

	return rb_iv_get(self, "tracks");
}


static VALUE
rb_despotify_playlist_search_more(VALUE self) {
	PLAYLIST_METHOD_HEADER
	despotify_playlist *pl;
	rb_despotify_session *session;

	if (pls->real->search) {
		VALUE2SESSION(rb_iv_get(self, "session"), session);
		rb_iv_set(self, "tracks", Qnil);
		despotify_search_more(session->real, pls->real);

		return self;
	}

	return Qnil;
}

static VALUE
rb_despotify_playlist_search_info(VALUE self) {
	PLAYLIST_METHOD_HEADER
	VALUE search;

	if (pls->real->search && rb_iv_get(self, "search_info") == Qnil) {
		search = rb_hash_new();

		HASH_VALUE_ADD(search, "query", rb_str_new2(
		               pls->real->search->query));

		HASH_VALUE_ADD(search, "suggestion", rb_str_new2(
		               pls->real->search->suggestion));

		HASH_VALUE_ADD(search, "total_artists", INT2NUM(
		               pls->real->search->total_artists));

		HASH_VALUE_ADD(search, "total_albums", INT2NUM(
		               pls->real->search->total_albums));

		HASH_VALUE_ADD(search, "total_tracks", INT2NUM(
		               pls->real->search->total_tracks));

		rb_iv_set(self, "search_info", search);
	}

	return rb_iv_get(self, "search_info");
}

static VALUE
rb_despotify_playlist_name(VALUE self) {
	PLAYLIST_METHOD_HEADER

	return rb_str_new2(pls->real->name);
}


static VALUE
rb_despotify_playlist_author(VALUE self) {
	PLAYLIST_METHOD_HEADER

	return rb_str_new2(pls->real->author);
}

static VALUE
rb_despotify_playlist_id(VALUE self) {
	PLAYLIST_METHOD_HEADER

	return rb_str_new2(pls->real->playlist_id);
}


VALUE
Init_despotify_playlist(VALUE mDespotify) {
	VALUE c;

	/* Despotify::Playlist */
	c = rb_define_class_under(mDespotify, "Playlist", rb_cObject);
	rb_define_alloc_func (c, rb_despotify_playlist_alloc);

	rb_define_method(c, "initialize", rb_despotify_playlist_new, 2);
	rb_define_method(c, "tracks", rb_despotify_playlist_tracks, 0);
	rb_define_method(c, "search_more", rb_despotify_playlist_search_more, 0);
	rb_define_method(c, "search_info", rb_despotify_playlist_search_info, 0);
	rb_define_method(c, "name", rb_despotify_playlist_name, 0);
	rb_define_method(c, "author", rb_despotify_playlist_author, 0);
	rb_define_method(c, "id", rb_despotify_playlist_id, 0);

	return c;
}
