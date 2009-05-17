/*
 * $Id$
 *
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <assert.h>
#include "network.h"

#include "auth.h"
#include "buf.h"
#include "hmac.h"
#include "session.h"
#include "keyexchange.h"
#include "util.h"

int send_client_initial_packet (SESSION *);
int read_server_initial_packet (SESSION *);

/*
 * Handle the first four packets
 *
 */
int do_key_exchange (SESSION * session)
{
	if (send_client_initial_packet (session)) {
		DSFYDEBUG("send_client_initial_packet() failed\n");
		return -1;
	}

	int ret = read_server_initial_packet(session);
	if (ret < 0) {
		DSFYDEBUG("read_server_initial_packet() failed\n");
		return ret;
	}

	return 0;
}

int send_client_initial_packet (SESSION * session)
{
	int ret;
	unsigned int len_idx;
	
	struct buf* b = buf_new();

	buf_append_u16 (b, 3); /* protocol version */

	len_idx = b->len;
	buf_append_u16(b, 0); /* packet length - updated later */
	buf_append_u32(b, 0); /* unknown */
	buf_append_u32(b, 0x00030c00); /* unknown */
	buf_append_u32(b, session->client_revision);
	buf_append_u32(b, 0); /* unknown */
	buf_append_u32(b, 0x01000000); /* unknown */
	buf_append_data(b, session->client_id, 4);
	buf_append_u32(b, 0); /* unknown */
	buf_append_data (b, session->client_random_16, 16);
	buf_append_data (b, session->my_pub_key, 96);

	BN_bn2bin (session->rsa->n, session->rsa_pub_exp);
	buf_append_data (b, session->rsa_pub_exp, sizeof(session->rsa_pub_exp));

	buf_append_u8 (b, 0); /* length of random data */
	buf_append_u8 (b, session->username_len);
	buf_append_u16(b, 0x0100); /* unknown */
        /* <-- random data would go here */
	buf_append_data (b, (unsigned char *) session->username,
			   session->username_len);
	buf_append_u8 (b, 0x40); /* unknown */

	/*
	 * Update length bytes
	 *
	 */
	b->ptr[len_idx] = (b->len >> 8) & 0xff;
	b->ptr[len_idx+1] = b->len & 0xff;

#ifdef DEBUG_LOGIN
	hexdump8x32 ("initial client packet", b->ptr, b->len);
#endif
        ret = sock_send(session->ap_sock, b->ptr, b->len);
	if (ret <= 0) {
		DSFYDEBUG("connection lost\n");
		buf_free(b);
		return -1;
	}
	else if (ret != b->len) {
                DSFYDEBUG("only wrote %d of %d bytes\n", ret, b->len);
		buf_free(b);
		return -1;
	}

        /* save initial server packet for auth hmac generation */
        session->init_client_packet = b;
	
	return 0;
}

int read_server_initial_packet (SESSION * session)
{
	char buf[512];
	unsigned char padlen;
	int ret;
        struct buf* save = buf_new();

        /* read 2 status bytes */
        ret = block_read(session->ap_sock, session->server_random_16, 2);
	if (ret < 2) {
            DSFYDEBUG("Failed to read status bytes\n");
            DSFYDEBUG("Remote host was %s:%d\n",
                      session->server_host, session->server_port);
            if (ret > 0)
                hexdump8x32
                    ("read_server_initial_packet, server_random_16",
                     session->server_random_16, ret);
            return -90;
	}

#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_initial_packet, server_random_16",
		     session->server_random_16, ret);
#endif

        if (session->server_random_16[0] != 0) {
            DSFYDEBUG("Bad response: %#02x %#02x\n",
                      session->server_random_16[0],
                      session->server_random_16[1]);
            switch (session->server_random_16[1]) {
                case 1: /* client upgrade required */
                    return -11;
                    
                case 3: /* user not found */
                    return -13;
                    
                case 4: /* account has been disabled */
                    return -14;
                    
                case 6: /* you need to complete your account details */
                    return -16;
                    
                case 9: /* country mismatch */
                    return -19;
                    
                default: /* unknown error */
                    return -91;
            }
        }

        /* read remaining 14 random bytes */
        ret = block_read(session->ap_sock, session->server_random_16 + 2, 14);
	if (ret < 14) {
            DSFYDEBUG("Failed to read server random\n");
            DSFYDEBUG("Remote host was %s:%d\n",
                      session->server_host, session->server_port);
            if (ret > 0)
                hexdump8x32("read_server_initial_packet, server_random_16",
                            session->server_random_16+2, ret);
            return -92;
	}
        buf_append_data(save, session->server_random_16, 16);
	
        /* read public key */
        ret = block_read(session->ap_sock, session->remote_pub_key, 96);
	if (ret != 96) {
            DSFYDEBUG("Failed to read 'remote_pub_key'\n");
            return -93;
	}
        buf_append_data(save, session->remote_pub_key, 96);
#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_initial_packet, server pub key",
		     session->remote_pub_key, 96);
#endif

        /* read server blob */
        ret = block_read(session->ap_sock, session->random_256, 256);
	if (ret != 256) {
            DSFYDEBUG("Failed to read 'random_256', got %d of 256 bytes\n", ret);
            return -94;
	}
        buf_append_data(save, session->random_256, 256);
#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_initial_packet, random_256",
		     session->random_256, 256);
#endif

        /* read salt */
        ret = block_read(session->ap_sock, session->salt, 10);
	if (ret != 10) {
            DSFYDEBUG("Failed to read 'salt'\n");
            return -95;
	}
        buf_append_data(save, session->salt, 10);
#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_initial_packet, salt", session->salt, 10);
#endif

        /* read padding length */
        ret = block_read(session->ap_sock, &padlen, 1);
	if (ret != 1) {
            DSFYDEBUG("Failed to read 'padding length'\n");
            return -96;
	}
	assert (padlen > 0);
        buf_append_u8(save, padlen);

        /* read username length */
        ret = block_read(session->ap_sock, &session->username_len, 1);
	if (ret != 1) {
            DSFYDEBUG("Failed to read 'username_len'\n");
            return -97;
	}
        buf_append_u8(save, session->username_len);
                
        /* read challenge lengths */
        unsigned short chalen[4];
        ret = block_read(session->ap_sock, chalen, 8);
	if (ret != 8) {
            DSFYDEBUG("Failed to read challenge lengths\n");
            return -98;
	}
        buf_append_data(save, chalen, 8);
        
        /* read packet padding */
        ret = block_read(session->ap_sock, buf, padlen);
	if (ret != padlen) {
            DSFYDEBUG("Failed to read 'padding'\n");
            return -99;
	}
        buf_append_data(save, buf, padlen);
#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_initial_packet, padding", buf, padlen);
#endif

        /* read username */
        ret = block_read(session->ap_sock,
                         session->username, session->username_len);
	if (ret != session->username_len) {
            DSFYDEBUG("Failed to read 'username'\n");
            return -100;
	}
        buf_append_data(save, session->username, session->username_len);
	session->username[session->username_len] = 0;
#ifdef DEBUG_LOGIN
	hexdump8x32 ("read_server_initial_packet, username",
		     session->username, session->username_len);
#endif

        /* read puzzle challenge */
        {
            int puzzle_len = ntohs(chalen[0]);
            int len1 = ntohs(chalen[1]);
            int len2 = ntohs(chalen[2]);
            int len3 = ntohs(chalen[3]);
            int totlen = puzzle_len + len1 + len2 + len3;

            struct buf* b = buf_new();
            buf_extend(b, totlen);
            
            ret = block_read(session->ap_sock, b->ptr, totlen);
            if (ret != totlen) {
                DSFYDEBUG("Failed to read puzzle\n");
                buf_free(b);
                return -101;
            }
            buf_append_data(save, b->ptr, totlen);
#ifdef DEBUG_LOGIN
            hexdump8x32("read_server_initial_packet, puzzle", b->ptr, totlen);
#endif
            

            if (b->ptr[0] == 1) {
                session->puzzle_denominator = b->ptr[1];
                session->puzzle_magic = ntohl( *((int*)(b->ptr + 2)));
            }
            else {
                DSFYDEBUG("Unexpected puzzle challenge\n");
                hexdump8x32("read_server_initial_packet, puzzle", b->ptr, totlen);
                buf_free(b);
                return -102;
            }

            buf_free(b);
        }

        session->init_server_packet = save;
        
	return 0;
}

/*
 * Initialize common crypto keys used for communication
 *
 * This step takes place after the initial two packets
 * have been exchanged.
 *
 */
void key_init (SESSION * session)
{
	BIGNUM *pub_key;
	unsigned char message[53];
	unsigned char hmac_output[20 * 5];
	unsigned char *ptr, *hmac_ptr;
	unsigned int mac_len;
	int i;

	/*
	 * Compute DH shared key
	 * It's used in the call to HMAC() below
	 *
	 * It's funny how the assert() triggers every now and then.
	 * OpenSSL might be more careful with the primes than Spotify's
	 * own libtommath-based implementation is.
	 *
	 */
	pub_key = BN_bin2bn (session->remote_pub_key, 96, NULL);
	if ((i =
	     DH_compute_key (session->shared_key, pub_key,
			     session->dh)) < 0) {
		FILE *fd = fopen ("/tmp/despotify-spotify-pubkey", "w");
		fwrite (pub_key, 1, 96, fd);
		fclose (fd);
		fprintf (stderr,
			 "Failed to compute shared key, error code %d\n", i);
		exit (1);
	}

#ifdef DEBUG_LOGIN
	hexdump8x32 ("key_init, my private key", session->my_priv_key, 96);
	hexdump8x32 ("key_init, my public key", session->my_pub_key, 96);
	hexdump8x32 ("key_init, remote public key", session->remote_pub_key,
		     96);
	hexdump8x32 ("key_init, shared key", session->shared_key, 96);
#endif
        BN_free(pub_key);

	/*
	 * Prepare a message to authenticate.
	 *
	 * Prior to the 19th of December 2008 Spotify happily told clients 
	 * (including ours!) almost everything it knew about a particular
	 * user, if they asked for it.
	 *
	 * Legitimate requests for this is for example when you add
	 * someone else's shared playlist.
	 *
	 * This allowed clients to see not only the last four digits of the 
	 * credit card used to subscribe to the premium service, whether
	 * the user was a paying customer or preferred commercials, but 
	 * also very interesting stuff such as the hash computed from
	 * SHA(salt || " " || password).
	 *
	 * In theory (HE HE!) this allowed any registered user to request
	 * somebody else's user data, get ahold of the hash, and then use
	 * it to authenticate as that user.
	 *
	 * Fortunately, at lest for Spotify and it's users, this is not
	 * the case anymore. (R.I.P poor misfeature)
	 *
	 * However, we urge people to change their passwords for reasons
	 * left as an exercise for the reader to figure out.
	 *
	 */
	ptr = message;
	memcpy (ptr, session->auth_hash, sizeof (session->auth_hash));
	ptr += sizeof (session->auth_hash);

	memcpy (ptr, session->client_random_16, 16);
	ptr += 16;

	memcpy (ptr, session->server_random_16, 16);
	ptr += 16;

	/*
	 * Run HMAC over the message, using the DH shared key as key
	 *
	 */
	hmac_ptr = hmac_output;
	mac_len = 20;
	for (i = 1; i <= 5; i++) {
		/*
		 * Change last byte of message to authenticate
		 *
		 */
		*ptr = i;

#ifdef DEBUG_LOGIN
		hexdump8x32 ("key_init, HMAC message", message,
			     sizeof (message));
#endif

	        sha1_hmac(session->shared_key, 96, message,
			  sizeof (message), hmac_ptr);
		
		/*
		 * Overwrite the 20 first bytes of the message with output from this round
		 *
		 */
		memcpy (message, hmac_ptr, 20);
		hmac_ptr += 20;
	}

	/*
	 * Use computed HMAC to setup keys for the
	 * stream cipher
	 *
	 */
	memcpy (session->key_send, hmac_output + 20, 32);
	memcpy (session->key_recv, hmac_output + 52, 32);

	shn_key (&session->shn_send, session->key_send, 32);
	shn_key (&session->shn_recv, session->key_recv, 32);
	session->key_send_IV = 0;
	session->key_recv_IV = 0;

	/*
	 * The first 20 bytes of the HMAC output is used
	 * to key another HMAC computed for the second
	 * authentication packet sent by the client.
	 *
	 */
	memcpy (session->key_hmac, hmac_output, 20);

#ifdef DEBUG_LOGIN
	hexdump8x32 ("key_init, key_hmac", session->key_hmac, 20);
	hexdump8x32 ("key_init, key_send", session->key_send, 32);
	hexdump8x32 ("key_init, key_recv", session->key_recv, 32);
#endif
}
