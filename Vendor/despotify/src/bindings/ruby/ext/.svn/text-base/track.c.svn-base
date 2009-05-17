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

#define TRACK_METHOD_HEADER \
	rb_despotify_track *track; \
	VALUE2TRACK(self, track);


static VALUE
rb_despotify_track_alloc(VALUE klass) {
	rb_despotify_track *track;
	VALUE obj = Data_Make_Struct(klass, rb_despotify_track,
	                             NULL, free, track);

	return obj;
}

static VALUE
rb_despotify_track_new(VALUE self) {
	return self;
}

VALUE
rb_despotify_track_new_from_track(despotify_track *t) {
	VALUE obj;
	rb_despotify_track *track;

	if(!t)
		return Qnil;

	obj = rb_despotify_track_alloc(cTrack);
	VALUE2TRACK(obj, track);

	track->real = t;

	return obj;
}

static VALUE
rb_despotify_track_metadata(VALUE self) {
	TRACK_METHOD_HEADER

	if (rb_iv_get(self, "metadata") == Qnil) {
		VALUE metadata = rb_hash_new();
		VALUE artists = rb_ary_new();
		VALUE artistids = rb_ary_new();
		despotify_artist *a;

		for (a = track->real->artist; a; a = a->next) {
			rb_ary_push(artistids, rb_str_new2(a->id));
			rb_ary_push(artists, rb_str_new2(a->name));
		}

		HASH_VALUE_ADD(metadata, "id", rb_str_new2(track->real->track_id));
		HASH_VALUE_ADD(metadata, "artist", artists);
		HASH_VALUE_ADD(metadata, "artist_id", artistids);
		HASH_VALUE_ADD(metadata, "album", rb_str_new2(track->real->album));
		HASH_VALUE_ADD(metadata, "title", rb_str_new2(track->real->title));
		HASH_VALUE_ADD(metadata, "length", INT2NUM(track->real->length));
		HASH_VALUE_ADD(metadata, "tracknumber", INT2NUM(track->real->tracknumber));
		HASH_VALUE_ADD(metadata, "year", INT2NUM(track->real->year));
		HASH_VALUE_ADD(metadata, "file_id", rb_str_new2(track->real->file_id));
		HASH_VALUE_ADD(metadata, "album_id", rb_str_new2(track->real->album_id));
		HASH_VALUE_ADD(metadata, "cover_id", rb_str_new2(track->real->cover_id));
		HASH_VALUE_ADD(metadata, "playable", BOOL2VALUE(track->real->playable));
		HASH_VALUE_ADD(metadata, "popularity", rb_float_new(track->real->popularity));

		rb_iv_set(self, "metadata", metadata);
	}

	return rb_iv_get(self, "metadata");
}

static VALUE
rb_despotify_track_lookup(VALUE self, VALUE key) {
	TRACK_METHOD_HEADER

	VALUE metadata;

	metadata = rb_despotify_track_metadata(self);

	return rb_hash_aref(metadata, key);
}



VALUE
Init_despotify_track(VALUE mDespotify) {
	VALUE c;

	/* Despotify::Track */
	c = rb_define_class_under(mDespotify, "Track", rb_cObject);

	/* Remove new function until we can request track by id */
	rb_undef_method (rb_singleton_class (c), "new");

	rb_define_method(c, "[]", rb_despotify_track_lookup, 1);
	rb_define_method(c, "metadata", rb_despotify_track_metadata, 0);

	return c;
}
