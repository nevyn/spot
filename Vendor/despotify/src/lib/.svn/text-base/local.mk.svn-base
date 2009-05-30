#
# $Id$
# 

LIB_OBJS = aes.lo audio.lo auth.lo buf.lo channel.lo commands.lo dns.lo ezxml.lo handlers.lo keyexchange.lo packet.lo puzzle.lo session.lo shn.lo sndqueue.lo util.lo network.lo despotify.lo sha1.lo hmac.lo xml.lo 

CFLAGS += -Igstapp/
LDFLAGS += -rpath /usr/lib
LDCONFIG = ldconfig

.PHONY: all clean install uninstall

all: libdespotify.la

# Mac OS X specifics
ifeq ($(shell uname -s),Darwin)
    LIB_OBJS += coreaudio.lo
    LDFLAGS += -lresolv -framework CoreAudio
    LDCONFIG = true
endif

# Windows specifics
ifeq ($(firstword $(subst _, ,$(shell uname -s))), MINGW32)
    LDFLAGS += -lwsock32 -lDnsapi
endif

# Linux specifics
ifeq ($(shell uname -s),Linux)
    LDFLAGS += -lresolv
    ifeq ($(LINUX_BACKEND),gstreamer)
        CFLAGS += $(shell pkg-config --cflags gstreamer-base-0.10)
        LDFLAGS += $(shell pkg-config --libs-only-l --libs-only-L gstreamer-base-0.10)

        LIB_OBJS += gstreamer.lo
        LIB_OBJS += gstapp/gstappsrc.lo gstapp/gstappbuffer.lo gstapp/gstapp-marshal.lo

gstapp/gstapp-marshal.h: gstapp/gstapp-marshal.list
	glib-genmarshal --header --prefix=gst_app_marshal gstapp/gstapp-marshal.list > gstapp/gstapp-marshal.h.tmp
	mv gstapp/gstapp-marshal.h.tmp gstapp/gstapp-marshal.h

gstapp/gstapp-marshal.c: gstapp/gstapp-marshal.list gstapp/gstapp-marshal.h
	echo "#include \"gstapp-marshal.h\"" >> gstapp/gstapp-marshal.c.tmp
	glib-genmarshal --body --prefix=gst_app_marshal gstapp/gstapp-marshal.list >> gstapp/gstapp-marshal.c.tmp
	mv gstapp/gstapp-marshal.c.tmp gstapp/gstapp-marshal.c

        ifeq ($(MAEMO4),1)
            CFLAGS += -DMAEMO4
        endif
    endif

    ifeq ($(LINUX_BACKEND),libao)
        LIB_OBJS += libao.lo
        LDFLAGS += -lao
    endif

    ifeq ($(LINUX_BACKEND),pulseaudio)
        LIB_OBJS += pulseaudio.lo
        LDFLAGS += -lpulse -lpulse-simple
    endif
endif

# FreeBSD specifics
ifeq ($(shell uname -s),FreeBSD)
    LIB_OBJS += pulseaudio.lo
    CFLAGS += -I/usr/local/include
    LDFLAGS += -L/usr/local/include -lpulse -lpulse-simple
endif

libdespotify.la: $(LIB_OBJS)
	@echo LD $@
	$(SILENT)$(LT) --mode=link $(CC) -o libdespotify.la $(LDFLAGS) $(LIB_OBJS)

%.lo: %.c
	@echo CC $<
	$(SILENT)$(LT) --mode=compile $(CC) $(CFLAGS) -o $@ -c $<

ifeq (,$(filter clean, $(MAKECMDGOALS))) # don't make deps for "make clean"
CFILES = $(LIB_OBJS:.lo=.c)

Makefile.dep: $(CFILES)
	@echo Generating dependencies
	$(SILENT)$(CC) $(CFLAGS) -MM $(CFILES) | sed 's/^\([^ ]\+\).o:/\1.lo:/' > $@

-include Makefile.dep
endif

clean:
	$(LT) --mode=clean rm -f $(LIB_OBJS) Makefile.dep

install: libdespotify.la
	install -d $(INSTALL_PREFIX)/lib/pkgconfig
	 
	$(LT) --mode=install install libdespotify.la $(INSTALL_PREFIX)/lib/libdespotify.la
	$(LDCONFIG) -n $(INSTALL_PREFIX)/lib
	
	install despotify.h $(INSTALL_PREFIX)/include/
	install despotify.pc $(INSTALL_PREFIX)/lib/pkgconfig/despotify.pc

uninstall:
	$(LT) --mode=uninstall rm -f $(INSTALL_PREFIX)/lib/libdespotify.la
	
	rm -fr $(INSTALL_PREFIX)/include/despotify/
	rm -f $(INSTALL_PREFIX)/lib/pkgconfig/despotify.pc
