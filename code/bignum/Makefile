HACL_HOME=$(realpath ../..)

# CUSTOMIZE HERE: determine what is the main target of this Makefile, e.g. a C
# test, a Low* test, or just a binary archive (like libcurve.a).
all: dist/bignum-test.exe

# Defines rules for producing .checked, .krml, .depend, etc.
include $(HACL_HOME)/Makefile.local

CFLAGS += -I$(HACL_HOME)/lib/c -march=native -mtune=native -O3 -DCOMPILE_INTRINSICS
export CFLAGS

# CUSTOMIZE HERE: how to produce binary objects
# An archive with all the compiled code in this directory.
dist/libbignum.a: dist/Makefile.basic
	$(MAKE) -C dist -f Makefile.basic

BIGNUM_BUNDLE= -bundle Hacl.Bignum.Base -static-header Hacl.Bignum.Base \
	-bundle Hacl.Bignum,Hacl.Bignum.*[rename=Hacl_Bignum]

dist/Makefile.basic: $(ALL_KRML_FILES)
	$(KRML) $^ -o libbignum.a $(BASE_FLAGS) $(BIGNUM_BUNDLE) \
	-tmpdir dist \
	-add-include '"lib_intrinsics.h"' \
	-fbuiltin-uint128 \
	-skip-compilation

dist/bignum-test.exe: $(HACL_HOME)/tests/bignum4096-test.o dist/libbignum.a

%.exe:
	$(CC) $(CFLAGS) $^ -o $@

clean-c:
	$(MAKE) -C dist/ -f Makefile.basic clean
