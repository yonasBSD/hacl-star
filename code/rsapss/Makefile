HACL_HOME=$(realpath ../..)

# CUSTOMIZE HERE: determine what is the main target of this Makefile, e.g. a C
# test, a Low* test, or just a binary archive (like libcurve.a).
all: dist/rsapss-test.exe

test: all
	dist/rsapss-test.exe

# Defines rules for producing .checked, .krml, .depend, etc.
include $(HACL_HOME)/Makefile.local

CFLAGS += -I$(HACL_HOME)/lib/c -march=native -mtune=native -O3 -DCOMPILE_INTRINSICS
export CFLAGS

# CUSTOMIZE HERE: how to produce binary objects
# An archive with all the compiled code in this directory.
dist/librsapss.a: dist/Makefile.basic
	$(MAKE) -C dist -f Makefile.basic

SHA2_BUNDLE=-bundle Hacl.Hash.SHA2=Hacl.Hash.*
BIGNUM_BUNDLE= -bundle Hacl.Bignum.Base -static-header Hacl.Bignum.Base \
	-bundle Hacl.Bignum,Hacl.Bignum.*[rename=Hacl_Bignum]
RSAPSS_BUNDLE=-bundle Hacl.RSAPSS=Hacl.Impl.RSAPSS.*,Hacl.Impl.RSAPSS[rename=Hacl_RSAPSS]

dist/Makefile.basic: $(ALL_KRML_FILES)
	$(KRML) $^ -o librsapss.a $(BASE_FLAGS) $(SHA2_BUNDLE) $(BIGNUM_BUNDLE) $(RSAPSS_BUNDLE) \
	-tmpdir dist \
	-add-include '"lib_intrinsics.h"' \
	-fbuiltin-uint128 \
	-skip-compilation

dist/rsapss-test.exe: $(HACL_HOME)/tests/rsapss-test.o dist/librsapss.a

%.exe:
	$(CC) $(CFLAGS) $^ -o $@

clean-c:
	$(MAKE) -C dist/ -f Makefile.basic clean
