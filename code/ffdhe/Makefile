HACL_HOME=$(realpath ../..)

# CUSTOMIZE HERE: determine what is the main target of this Makefile, e.g. a C
# test, a Low* test, or just a binary archive (like libcurve.a).
all: dist/ffdhe-test.exe

# Defines rules for producing .checked, .krml, .depend, etc.
include $(HACL_HOME)/Makefile.local

CFLAGS += -I$(HACL_HOME)/lib/c -march=native -mtune=native -O3 -DCOMPILE_INTRINSICS
export CFLAGS

# CUSTOMIZE HERE: how to produce binary objects
# An archive with all the compiled code in this directory.
dist/libffdhe.a: dist/Makefile.basic
	$(MAKE) -C dist -f Makefile.basic

BIGNUM_BUNDLE= -bundle Hacl.Bignum.Base -static-header Hacl.Bignum.Base \
	-bundle Hacl.Bignum,Hacl.Bignum.*[rename=Hacl_Bignum]
FFDHE_BUNDLE=-bundle Hacl.Impl.FFDHE.Constants -static-header Hacl.Impl.FFDHE.Constants -bundle Hacl.FFDHE=Hacl.Impl.FFDHE[rename=Hacl_FFDHE]

dist/Makefile.basic: $(ALL_KRML_FILES)
	$(KRML) $^ -o libffdhe.a $(BASE_FLAGS) $(BIGNUM_BUNDLE) $(FFDHE_BUNDLE) \
	-tmpdir dist \
	-add-include '"lib_intrinsics.h"' \
	-fbuiltin-uint128 \
	-skip-compilation

dist/ffdhe-test.exe: $(HACL_HOME)/tests/ffdhe-test.o dist/libffdhe.a

%.exe:
	$(CC) $(CFLAGS) $^ -o $@

clean-c:
	$(MAKE) -C dist/ -f Makefile.basic clean
