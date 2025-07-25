HACL_HOME=$(realpath ../..)

# CUSTOMIZE HERE: determine what is the main target of this Makefile, e.g. a C
# test, a Low* test, or just a binary archive (like libcurve.a).
all: dist/libed25519.a

# Defines rules for producing .checked, .krml, .depend, etc.
include $(HACL_HOME)/Makefile.local

CFLAGS += -I$(HACL_HOME)/lib/c -march=native -mtune=native -O3
export CFLAGS

# CUSTOMIZE HERE: how to produce binary objects
# An archive with all the compiled code in this directory.
dist/libed25519.a: dist/Makefile.basic
	$(MAKE) -C dist -f Makefile.basic

HASH_BUNDLE=-bundle Hacl.Hash.SHA2+Hacl.Hash.Core.SHA2+Hacl.Hash.Definitions=Hacl.Hash.*[rename=Hacl_Hash]
STREAMING_BUNDLE=-bundle Hacl.Streaming.*
BLAKE2_BUNDLE=-bundle Hacl.Impl.Blake2.Constants -static-header Hacl.Impl.Blake2.Constants -bundle 'Hacl.Impl.Blake2.\*'
CURVE_BUNDLE=-bundle Hacl.Impl.Curve25519.Field51[rename=Hacl_Bignum25519_51] -static-header Hacl.Impl.Curve25519.Field51 \
	-bundle Hacl.Curve25519_51,Hacl.Impl.Curve25519.Field51,Hacl.Impl.Curve25519.*[rename=Hacl_Curve25519]

dist/Makefile.basic: $(ALL_KRML_FILES)
	$(KRML) $^ -o libed25519.a \
	-bundle Lib.PrintBuffer= \
	$(BASE_FLAGS) $(HASH_BUNDLE) $(STREAMING_BUNDLE) $(BLAKE2_BUNDLE) \
	$(CURVE_BUNDLE) $(BIGNUM_BUNDLE) $(ED_BUNDLE) \
	-tmpdir dist \
	-no-prefix 'Hacl.Test.Ed25519' \
	-fbuiltin-uint128 \
	-skip-compilation

dist/ed25519-test.exe: dist/libed25519.a \
	$(KRML_HOME)/krmllib/dist/generic/libkrmllib.a $(HACL_HOME)/lib/c/Lib_PrintBuffer.c

%.exe:
	$(CC) $(CFLAGS) $^ -o $@

clean-c:
	$(MAKE) -C dist/ -f Makefile.basic clean
