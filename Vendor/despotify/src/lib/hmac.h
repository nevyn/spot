/*
 * $Id: hmac.h 182 2009-03-12 08:21:53Z zagor $
 *
 */

#ifndef DESPOTIFY_HMAC_H
#define DESPOTIFY_HMAC_H

void sha1_hmac(unsigned char *inputkey, size_t inputkeylen,
               unsigned char *inputmsg, size_t msglen,
               unsigned char *dst);
#endif
