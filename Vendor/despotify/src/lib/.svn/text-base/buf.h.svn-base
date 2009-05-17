/*
 * Minimalistic extensible buffer implementation.
 *
 * Written by Björn Stenberg <bjorn@haxx.se>
 *
 * To the extent possible under law, I have waived all copyright and related
 * or neighboring rights to buf.c. This work is published from Sweden.
 * http://creativecommons.org/publicdomain/zero/1.0/
 *
 * $Id$
 */

#ifndef _BUF_H_
#define _BUF_H_

struct buf {
    unsigned char* ptr;
    int len;
    int size;
};

void* buf_new(void);
void buf_free(struct buf* b);
void buf_extend(struct buf* b, int len);
void buf_append_data(struct buf* b, void* data, int len);
void buf_append_u8(struct buf* b, unsigned char data);
void buf_append_u16(struct buf* b, unsigned short data);
void buf_append_u32(struct buf* b, unsigned long data);

#endif
