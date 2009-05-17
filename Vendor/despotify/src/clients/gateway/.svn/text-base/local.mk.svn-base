#
# $Id$
# 

unexport LDFLAGS CFLAGS

LIBDIR = ../../lib
LIB = $(LIBDIR)/libdespotify.la

CFLAGS += -I$(LIBDIR)

GATEWAY_OBJS = gw-core.o gw-browse.o gw-handlers.o gw-image.o gw-playlist.o gw-search.o gw-stream.o gw-http.o base64.o

.PHONY: all clean install uninstall
all: gateway

# These are the files we depgen for. :-)
CFILES = $(GATEWAY_OBJS:.o=.c)
include ../depgen.mk

%.o: %.c
	@echo CC $<
	$(SILENT)$(CC) $(CFLAGS) -o $@ -c $<

clean:
	$(LT) --mode=clean rm -f gateway
	rm -f $(GATEWAY_OBJS) Makefile.dep

gateway: $(GATEWAY_OBJS) $(LIB)
	@echo LD $@
	$(SILENT)$(LT) --mode=link $(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(LIB) $(GATEWAY_OBJS)

install: gateway 
	@echo "Copying gateway binary to $(INSTALL_PREFIX)/bin/gateway"
	$(LT) --mode=install install gateway $(INSTALL_PREFIX)/bin/gateway

uninstall:
	@echo "Removing gateway..."
	rm -f $(INSTALL_PREFIX)/bin/gateway
