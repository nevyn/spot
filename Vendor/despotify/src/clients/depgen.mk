# File that generates dependencies for whatever needs to be generated deps for.
ifeq (,$(filter clean, $(MAKECMDGOALS))) # don't make deps for "make clean"
Makefile.dep:
	@echo Generating dependencies
	@$(CC) $(CFLAGS) -MM $(CFILES) > $@

-include Makefile.dep
endif
