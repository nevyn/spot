/*
 * $Id$
 *
 * Cross platform networking for despotify
 *
 */
 
#include <stdlib.h>
#include <unistd.h>

#include "network.h"
 
// socket read, write
int sock_send (int sock, void *buf, size_t nbyte) {
  #ifdef __use_winsock__
	return send (sock, buf, nbyte, 0);
  #else
	return write (sock, buf, nbyte);
  #endif
}
int sock_recv (int sock, void *buf, size_t nbyte) {
  #ifdef __use_winsock__
	return recv (sock, buf, nbyte, 0);
  #else
	return read (sock, buf, nbyte);
  #endif
}
int sock_close (int sock) {
  #ifdef __use_winsock__
	return closesocket(sock);
  #else
	return close(sock);
  #endif
}
int network_init (void)
{
	#ifdef __use_winsock__
	WSADATA wsaData;
	if (WSAStartup(MAKEWORD(1,1), &wsaData) != 0) {
		fprintf (stderr, "Winsock failed. \n");
		return -1;
	}
	#endif
	return 0;
}
int network_cleanup (void)
{
	#ifdef __use_winsock__
	return WSACleanup();
	#endif
	return 0;
}
