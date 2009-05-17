#ifndef LIBDESPOTIFY_SIMPLE_H
#define LIBDESPOTIFY_SIMPLE_H

#include "despotify.h"

int despotify_play(SESSION *session, PLAYLIST *playlist, int initial_song);

int despotify_skip_song(SESSION *session);
int despotify_previous_song(SESSION *session); 

int despotify_queue_song(SESSION *session, TRACK *song);
int despotify_dequeue_song(SESSION *session, TRACK *song);

int despotify_set_shuffle(SESSION *session, int new_state);
int despotify_get_shuffle(SESSION *session);

int despotify_set_repeat(SESSION *session, int new_state);
int despotify_get_repeat(SESSION *session);

int despotify_set_volume(SESSION *session, int new_volume);
int despotify_get_volume(SESSION *session);

#endif
