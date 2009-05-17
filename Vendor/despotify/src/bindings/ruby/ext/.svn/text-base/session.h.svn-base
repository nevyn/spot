/*
 * $Id$
 */

#ifndef __RB_SESSION_H
#define __RB_SESSION_H

typedef struct {
	despotify_session *real;
	despotify_playlist *rootpl;
	bool connected;
} rb_despotify_session;

VALUE Init_despotify_session(VALUE mDespotify);


#define VALUE2SESSION(obj, var) \
	Data_Get_Struct ((obj), rb_despotify_session, (var))

#endif
