/*
 * Minimalistic extensible buffer implementation.
 *
 * Written by Björn Stenberg <bjorn@haxx.se>
 *
 * To the extent possible under law, I have waived all copyright and related
 * or neighboring rights to buf.c. This work is published from Sweden.
 * http://creativecommons.org/publicdomain/zero/1.0/
 *
 * $Id: buf.c 182 2009-03-12 08:21:53Z zagor $
 */

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "buf.h"

#define START_SIZE 512

void buf_extend(struct buf* b, int len)
{
    if (b->len + len > b->size) {
        while (b->len + len > b->size)
            b->size *= 2;
        b->ptr = realloc(b->ptr, b->size);
        assert(b->ptr);
    }
}

void* buf_new(void)
{
    struct buf* b = malloc(sizeof(struct buf));
    assert(b);
    b->len = 0;
    b->size = START_SIZE;
    b->ptr = malloc(START_SIZE);
    assert(b->ptr);

    return b;
}

void buf_free(struct buf* b)
{
    assert(b);
    assert(b->ptr);
    free(b->ptr);
    free(b);
}

void buf_append_data(struct buf* b, void* data, int len)
{
    buf_extend(b, len);

    memcpy(b->ptr + b->len, data, len);
    b->len += len;
}

void buf_append_u8(struct buf* b, unsigned char data)
{
    buf_extend(b, 1);

    b->ptr[b->len] = data;
    b->len += 1;
}

void buf_append_u16(struct buf* b, unsigned short data)
{
    buf_extend(b, 2);

    b->ptr[b->len] = (data >> 8) & 0xff;
    b->ptr[b->len+1] = data & 0xff;

    b->len += 2;
}

void buf_append_u32(struct buf* b, unsigned long data)
{
    buf_extend(b, 4);

    b->ptr[b->len] = (data >> 24) & 0xff;
    b->ptr[b->len+1] = (data >> 16) & 0xff;
    b->ptr[b->len+2] = (data >> 8) & 0xff;
    b->ptr[b->len+3] = data & 0xff;

    b->len += 4;
}
