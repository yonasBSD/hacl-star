HACL_HOME=$(realpath ../..)

# CUSTOMIZE HERE: determine what is the main target of this Makefile, e.g. a C
# test, a Low* test, or just a binary archive (like libcurve.a).
all: dist/libhpke.a

# Defines rules for producing .checked, .krml, .depend, etc.
include $(HACL_HOME)/Makefile.local

CFLAGS += -I$(HACL_HOME)/lib/c -march=native -mtune=native
export CFLAGS

# CUSTOMIZE HERE: how to produce binary objects
# An archive with all the compiled code in this directory.
dist/libhpke.a: dist/Makefile.basic
	$(MAKE) -C dist -f Makefile.basic

dist/Makefile.basic: $(ALL_KRML_FILES)
	$(KRML) $^ -o libhpke.a $(BASE_FLAGS) \
	  $(HPKE_BUNDLE) \
	  -tmpdir dist \
	  -ccopts -std=gnu11,-g,-O3 \
	  -add-include '"libintvector.h"' \
	  -skip-compilation

clean-c:
	$(MAKE) -C dist/ -f Makefile.basic clean


%.fst-in %.fsti-in:
	@echo $(FSTAR_INCLUDES) --load Meta.Interface
