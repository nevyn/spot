/*
 * $Id: puzzle.c 291 2009-04-08 14:22:33Z zagor $
 *
 * Zero-modulus bruteforce puzzle to prevent 
 * Denial of Service and password bruteforce attacks
 *
 */

#include <stdlib.h>
#include "network.h"

#include "puzzle.h"
#include "session.h"
#include "util.h"
#include "sha1.h"


#if !defined srandom || !defined random
#define srandom srand
#define random rand
#endif

void puzzle_solve (SESSION * session)
{
	SHA1_CTX ctx;
	unsigned char digest[20];
	unsigned int *nominator_from_hash;
	unsigned int denominator;
	int i;

	/*
	 * Modulus operation by a power of two.
	 * "Most programmers learn this trick early"
	 * Well, fuck me. I'm just here for the party.
	 *
	 */
	denominator = 1 << session->puzzle_denominator;
	denominator--;

	/*
	 * Compute a hash over random data until
	 * (last dword byteswapped XOR magic number) mod
	 * denominator by server produces zero.
	 *
	 */

	srandom (*(unsigned int *) &ctx);
	nominator_from_hash = (unsigned int *) (digest + 16);
	do {
		SHA1Init (&ctx);
		SHA1Update (&ctx, session->server_random_16, 16);

		/* Let's waste some precious pseudorandomness */
		for (i = 0; i < 8; i++)
			session->puzzle_solution[i] = random ();
		SHA1Update (&ctx, session->puzzle_solution, 8);

		SHA1Final (digest, &ctx);

		/* byteswap (XXX - htonl() won't work on bigendian machines!) */
		*nominator_from_hash = htonl (*nominator_from_hash);

		/* XOR with a fancy magic */
		*nominator_from_hash ^= session->puzzle_magic;
	} while (*nominator_from_hash & denominator);

#ifdef DEBUG_LOGIN
	hexdump8x32 ("auth_solve_puzzle, puzzle_solution",
		     session->puzzle_solution, 8);
#endif
}
