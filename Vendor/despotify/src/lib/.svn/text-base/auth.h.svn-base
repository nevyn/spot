/*
 * $Id$
 *
 */

#ifndef DESPOTIFY_AUTH_H
#define DESPOTIFY_AUTH_H

#include "session.h"

void auth_generate_auth_hash (SESSION *);
int do_auth (SESSION *);
void auth_solve_puzzle (SESSION *);
void auth_generate_auth_hmac (SESSION *, unsigned char *, unsigned int);

int send_client_auth (SESSION *);
int read_server_auth_response (SESSION *);
#endif
