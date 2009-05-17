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

#define ARTIST_METHOD_HEADER \
	rb_despotify_artist *artist; \
	VALUE2ARTIST(self, artist);


static void
rb_despotify_artist_free(rb_despotify_artist *artist) {
	if (artist->real)
		despotify_free_artist(artist->real);

	free(artist);
}

static VALUE
rb_despotify_artist_alloc(VALUE klass) {
	rb_despotify_artist *artist;

	VALUE obj = Data_Make_Struct(klass, rb_despotify_artist, NULL,
	                             rb_despotify_artist_free, artist);

	return obj;
}

VALUE
rb_despotify_artist_new_from_artist(despotify_artist *a) {
	VALUE obj;
	rb_despotify_artist *artist;

	if (!a)
		return Qnil;

	obj = rb_despotify_artist_alloc(cArtist);
	VALUE2ARTIST(obj, artist);

	artist->real = a;

	return obj;
}

static VALUE
rb_despotify_artist_new(VALUE self, VALUE session, VALUE id) {
	rb_despotify_session *sessionptr;
	rb_despotify_artist *artist;

	despotify_artist *a = NULL;
	unsigned char *artist_id;

	VALUE2ARTIST(self, artist);
	VALUE2SESSION(session, sessionptr);
	artist_id = StringValuePtr(id);

	CHECKIDLEN(artist_id, 32);

	a = despotify_get_artist(sessionptr->real, artist_id);
	if(!a)
		return Qnil;

	artist->real = a;

	if (rb_block_given_p())
		rb_yield(self);

	return self;
}


static VALUE
rb_despotify_artist_albums(VALUE self) {
	ARTIST_METHOD_HEADER

	if (rb_iv_get(self, "albums") == Qnil) {
		VALUE albums = rb_ary_new();
		despotify_album *a;

		for(a = artist->real->albums; a; a = a->next) {
			rb_ary_push(albums, rb_despotify_album_new_from_album(a, true));
		}

		rb_iv_set(self, "albums", albums);
	}

	return rb_iv_get(self, "albums");
}

static VALUE
rb_despotify_artist_metadata(VALUE self) {
	ARTIST_METHOD_HEADER

	if (rb_iv_get(self, "metadata") == Qnil) {
		VALUE metadata = rb_hash_new();

		HASH_VALUE_ADD(metadata, "name", rb_str_new2(artist->real->name));
		HASH_VALUE_ADD(metadata, "id", rb_str_new2(artist->real->id));
		if(artist->real->text)
			HASH_VALUE_ADD(metadata, "text", rb_str_new2(artist->real->text));
		HASH_VALUE_ADD(metadata, "portrait_id", rb_str_new2(artist->real->portrait_id));
		HASH_VALUE_ADD(metadata, "genres", rb_str_new2(artist->real->genres));
		HASH_VALUE_ADD(metadata, "years_active", rb_str_new2(artist->real->years_active));
		HASH_VALUE_ADD(metadata, "num_albums", INT2NUM(artist->real->num_albums));
		HASH_VALUE_ADD(metadata, "popularity", rb_float_new(artist->real->popularity));

		rb_iv_set(self, "metadata", metadata);
	}

	return rb_iv_get(self, "metadata");
}

static VALUE
rb_despotify_artist_lookup(VALUE self, VALUE key) {
	ARTIST_METHOD_HEADER
	VALUE metadata;

	metadata = rb_despotify_artist_metadata(self);

	return rb_hash_aref(metadata, key);
}


static VALUE
rb_despotify_artist_name(VALUE self) {
	ARTIST_METHOD_HEADER

	return rb_str_new2(artist->real->name);
}


static VALUE
rb_despotify_artist_id(VALUE self) {
	ARTIST_METHOD_HEADER

	return rb_str_new2(artist->real->id);
}


VALUE
Init_despotify_artist(VALUE mDespotify) {
	VALUE c;

	/* Despotify::Artist */
	c = rb_define_class_under(mDespotify, "Artist", rb_cObject);
	rb_define_alloc_func (c, rb_despotify_artist_alloc);

	rb_define_method(c, "initialize", rb_despotify_artist_new, 2);
	rb_define_method(c, "name", rb_despotify_artist_name, 0);
	rb_define_method(c, "id", rb_despotify_artist_id, 0);
	rb_define_method(c, "albums", rb_despotify_artist_albums, 0);

	rb_define_method(c, "[]", rb_despotify_artist_lookup, 1);
	rb_define_method(c, "metadata", rb_despotify_artist_metadata, 0);

	return c;
}
