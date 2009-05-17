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


static VALUE
rb_despotify_id2uri(VALUE self, VALUE id) {
	char *idptr;
	char buf[128];

	idptr = StringValuePtr(id);

	despotify_id2uri(idptr, buf);

	return rb_str_new2(buf);
}

static VALUE
rb_despotify_uri2id(VALUE self, VALUE uri) {
	char *uriptr;
	char buf[128];

	uriptr = StringValuePtr(uri);

	despotify_uri2id(uriptr, buf);

	return rb_str_new2(buf);
}

void
Init_despotify(void) {
	if (!despotify_init()) {
		printf("despotify_init() failed\n");
		return;
	}

	VALUE mDespotify = rb_define_module("Despotify");

	rb_define_singleton_method(mDespotify, "id2uri", rb_despotify_id2uri, 1);
	rb_define_singleton_method(mDespotify, "uri2id", rb_despotify_uri2id, 1);
	rb_define_const(mDespotify, "MAX_SEARCH_RESULTS", INT2NUM(MAX_SEARCH_RESULTS));

	cSession = Init_despotify_session(mDespotify);
	cPlaylist = Init_despotify_playlist(mDespotify);
	cTrack = Init_despotify_track(mDespotify);
	cArtist = Init_despotify_artist(mDespotify);
	cAlbum = Init_despotify_album(mDespotify);

	eDespotifyError = rb_define_class_under(mDespotify, "DespotifyError", rb_eException);
}

