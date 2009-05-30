/*
 * $Id$
 *
 * Code for dealing with authentication against
 * the server.
 *
 * Used after exchanging the two first packets to
 * exchange the next two packets.
 *
 */

#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include "network.h"

#include "auth.h"
#include "buf.h"
#include "puzzle.h"
#include "util.h"
#include "sha1.h"
#include "hmac.h"

void auth_generate_auth_hash (SESSION * session)
{
	SHA1_CTX ctx;

	SHA1Init (&ctx);

	SHA1Update (&ctx, session->salt, 10);
	SHA1Update (&ctx, " ", 1);
	SHA1Update (&ctx, session->password, strlen (session->password));

	SHA1Final (session->auth_hash, &ctx);

#ifdef DEBUG_LOGIN
	hexdump8x32 ("auth_generate_auth_hash, auth_hash", session->auth_hash,
		     20);
#endif
}

int do_auth (SESSION * session)
{
	/*
	 * !! cr4zy 0pp3rtun1ty 2 s4v3 s0m3 pr3c10uz 3n3rgy !@)#&$!@#
	 *
	 * g00gl3 w4z b4d but th1z 1z w0rz3 - w4zt1ng CPU cycl3z f0r
	 * th3 s4k3 0f w4zt1ng th3m & d3l4y1ng th3 l0g1n pr0c3zz,
	 *
	 * 3d1t0rz r3m4rk:
	 *   sk1pp1n' th1z l4m3 puzzl3 w0u1d b3 4n 4w3z0m3
	 *   1Ph0n3 b4tt3ry 0pt1m1z4t10n t3kn1qu3 !!
	 *
	 * b4ckgr0und th30ry
	 *   http://google.com/search?q=aura-nikander-leiwo-protocols00.pdf
	 *   http://google.com/search?q=005-candolin.pdf
	 *
	 */
	puzzle_solve (session);

	/*
	 * Compute HMAC over random data, public keys,
	 * more random data and finally some username-
	 * related parts
	 *
	 * Key is part of a digest computed in key_init()
	 *
	 */
	auth_generate_auth_hmac (session, session->auth_hmac,
				 sizeof (session->auth_hmac));

	if (send_client_auth (session)) {
		DSFYDEBUG("do_auth(): send_client_auth() failed\n");
		return -1;
	}

	if (read_server_auth_response (session)) {
		DSFYDEBUG("do_auth(): read_server_auth_response() failed\n");
		return -1;
	}

        if (session->init_client_packet)
            buf_free(session->init_client_packet);
        if (session->init_server_packet)
            buf_free(session->init_server_packet);
        
	return 0;
}

void auth_generate_auth_hmac (SESSION * session, unsigned char *auth_hmac,
			      unsigned int mac_len)
{
        (void)mac_len;
        struct buf* buf = buf_new();
	
	buf_append_data(buf, session->init_client_packet->ptr,
                        session->init_client_packet->len);
	buf_append_data(buf,  session->init_server_packet->ptr,
                        session->init_server_packet->len);
        buf_append_u8(buf, 0); /* random data length */
        buf_append_u8(buf, 0); /* unknown */
        buf_append_u16(buf, 8); /* puzzle solution length */
        buf_append_u32(buf, 0); /* unknown */
        /* <-- random data would go here */
        buf_append_data(buf, session->puzzle_solution, 8);

#ifdef DEBUG_LOGIN
	hexdump8x32 ("auth_generate_auth_hmac, HMAC message", buf->ptr,
		     buf->len);
	hexdump8x32 ("auth_generate_auth_hmac, HMAC key", session->key_hmac,
		     sizeof (session->key_hmac));
#endif

	sha1_hmac ( session->key_hmac, sizeof (session->key_hmac),
		    buf->ptr, buf->len, auth_hmac);

#ifdef DEBUG_LOGIN
	hexdump8x32 ("auth_generate_auth_hmac, HMAC digest", auth_hmac,
		     mac_len);
#endif

	buf_free(buf);
}

int send_client_auth (SESSION * session)
{
	int ret;
        struct buf* buf = buf_new();

	buf_append_data(buf, session->auth_hmac, 20);
        buf_append_u8(buf, 0); /* random data length */
        buf_append_u8(buf, 0); /* unknown */
        buf_append_u16(buf, 8); /* puzzle solution length */
        buf_append_u32(buf, 0);
        /* <-- random data would go here */
	buf_append_data (buf, session->puzzle_solution, 8);

#ifdef DEBUG_LOGIN
	hexdump8x32 ("send_client_auth, second client packet", buf->ptr,
		     buf->len);
#endif

        ret = sock_send(session->ap_sock, buf->ptr, buf->len);
	if (ret <= 0) {
		DSFYDEBUG("send_client_auth(): connection lost\n");
		buf_free(buf);
		return -1;
	}
	else if (ret != buf->len) {
		DSFYDEBUG("send_client_auth(): only wrote %d of %d bytes\n",
			ret, buf->len);
		buf_free(buf);
		return -1;
	}

	buf_free(buf);
	
	return 0;
}

int read_server_auth_response (SESSION * session)
{
	unsigned char buf[256];
	unsigned char payload_len;
	int ret;

        ret = block_read(session->ap_sock, buf, 2);
	if (ret != 2) {
            DSFYDEBUG("Failed to read 'status' + length byte, got %d bytes\n", ret);
            return -1;
	}

	if (buf[0] != 0x00) {
            DSFYDEBUG("Authentication failed with error 0x%02x, bad password?\n", buf[1]);
            return -1;
	}

	/* Payload length + this byte must not be zero(?) */
	assert (buf[1] > 0);

	payload_len = buf[1];

        ret = block_read (session->ap_sock, buf, payload_len);
	if (ret != payload_len) {
            DSFYDEBUG("Failed to read 'payload', got %d of %u bytes\n",
                      ret, payload_len);
            return -1;
	}
#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_auth_response, payload", buf, payload_len);
#endif

	return 0;
}
