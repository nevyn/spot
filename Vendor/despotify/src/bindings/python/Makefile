.PHONY: all src build install clean

all: src build

build:
	./setup.py build

src:
	$(MAKE) -C src/

install:
	./setup.py install

clean:
	$(RM) -r build/

distclean: clean
	$(MAKE) -C src/ clean
