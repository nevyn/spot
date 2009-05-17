# Local build settings. Do NOT edit Makefile, edit this instead.
# After a fresh checkout, you have to copy this to Makefile.local.mk.

## Enable debug output to /tmp/gui.log
# DEBUG = 1

## Disable GUI stuff
# NOGUI = 1

## Install prefix
# INSTALL_PREFIX = /usr

## Specify ncurses include path explicitly. (should contain curses.h)
# NCURSES_INCLUDE = /usr/local/include/ncursesw

## Choose audio backend
LINUX_BACKEND = gstreamer
# LINUX_BACKEND = pulseaudio
# LINUX_BACKEND = libao

## Add more CFLAGS
# CFLAGS += -DDEBUG_SNDQUEUE
# CFLAGS += -DDEBUG_PACKETS

CFLAGS += -I/opt/local/include
LDFLAGS += -L/opt/local/lib