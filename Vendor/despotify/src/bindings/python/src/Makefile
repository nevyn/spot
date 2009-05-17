SRCS = spytify.pyx

OUTS := $(SRCS:.pyx=.c)

CYTHON = cython

all: $(OUTS)

spytify.c: album.pxi artist.pxi despotify.pxd playlist.pxi \
           searchresult.pxi sessionstruct.pxi spytify.pxd spytify.pyx \
	   track.pxi

%.c: %.pyx
	$(CYTHON) `pkg-config --cflags-only-I despotify` -o $@ $< 

.PHONY: all clean

clean:
	$(RM) $(OUTS)
