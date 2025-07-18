module Hacl.Streaming.SHA2

// NOTE: if you get errors trying to load this file in interactive mode because
// a tactic fails in Hacl.Streaming.MD (even though Hacl.Streaming.MD works
// totally fine in interactive mode!!), run:
//     NODEPEND=1 make -j obj/Hacl.Streaming.MD.fst.checked

open FStar.HyperStack.ST

/// A streaming version of MD-based hashes

#set-options "--fuel 0 --ifuel 0 --z3rlimit 100"

module G = FStar.Ghost
module F = Hacl.Streaming.Functor

open Spec.Hash.Definitions
open Hacl.Streaming.Interface
open Hacl.Streaming.MD

/// Instantiations of the streaming functor for specialized SHA2 algorithms.
///
/// Some remarks:
///
/// - we don't bother with using the abstraction feature since we verified
///   clients like miTLS go through EverCrypt.Hash.Incremental

inline_for_extraction noextract
let hacl_sha2_224 = hacl_md SHA2_224
inline_for_extraction noextract
let hacl_sha2_256 = hacl_md SHA2_256
inline_for_extraction noextract
let hacl_sha2_384 = hacl_md SHA2_384
inline_for_extraction noextract
let hacl_sha2_512 = hacl_md SHA2_512

inline_for_extraction noextract
let state_224 = state_t SHA2_224
inline_for_extraction noextract
let state_256 = state_t SHA2_256
inline_for_extraction noextract
let state_384 = state_t SHA2_384
inline_for_extraction noextract
let state_512 = state_t SHA2_512

/// Type abbreviations - for pretty code generation
let state_t_224 = Hacl.Streaming.MD.state_32
let state_t_256 = Hacl.Streaming.MD.state_32
let state_t_384 = Hacl.Streaming.MD.state_64
let state_t_512 = Hacl.Streaming.MD.state_64

open Lib.Buffer
open Lib.IntTypes
open Lib.NTuple
open Lib.MultiBuffer
open Hacl.Spec.SHA2.Vec
open Hacl.SHA2.Scalar32
open Hacl.Impl.SHA2.Generic
module ST = FStar.HyperStack.ST

// SHA2-256
// --------

inline_for_extraction noextract
let alloca_256 = F.alloca hacl_sha2_256 () (state_256.s ()) (G.erased unit)

[@@ Comment
"Allocate initial state for the SHA2_256 hash. The state is to be freed by
calling `free_256`."]
let malloc_256 = F.malloc hacl_sha2_256 () (state_256.s ()) (G.erased unit)

[@@ Comment
"Copies the state passed as argument into a newly allocated state (deep copy).
The state is to be freed by calling `free_256`. Cloning the state this way is
useful, for instance, if your control-flow diverges and you need to feed
more (different) data into the hash in each branch."]
let copy_256 = F.copy hacl_sha2_256 () (state_256.s ()) (G.erased unit)

[@@ Comment
"Reset an existing state to the initial hash state with empty data."]
let reset_256 = F.reset hacl_sha2_256 (G.hide ()) (state_256.s ()) (G.erased unit)

[@@ CInline ]
private
let update_224_256 = F.update hacl_sha2_256 (G.hide ()) (state_256.s ()) (G.erased unit)

[@@ Comment
"Feed an arbitrary amount of data into the hash. This function returns 0 for
success, or 1 if the combined length of all of the data passed to `update_256`
(since the last call to `reset_256`) exceeds 2^61-1 bytes.

This function is identical to the update function for SHA2_224.";
]
let update_256: F.update_st hacl_sha2_256 (G.hide ()) (state_256.s ()) (G.erased unit) = fun state input input_len -> update_224_256 state input input_len

[@@ Comment
"Write the resulting hash into `output`, an array of 32 bytes. The state remains
valid after a call to `digest_256`, meaning the user may feed more data into
the hash via `update_256`. (The digest_256 function operates on an internal copy of
the state and therefore does not invalidate the client-held state `p`.)"]
let digest_256 = F.digest hacl_sha2_256 () (state_256.s ()) (G.erased unit)

[@@ Comment
"Free a state allocated with `malloc_256`.

This function is identical to the free function for SHA2_224."]
let free_256 = F.free hacl_sha2_256 (G.hide ()) (state_256.s ()) (G.erased unit)

[@@ Comment
"Hash `input`, of len `input_len`, into `output`, an array of 32 bytes."]
val hash_256: Hacl.Hash.Definitions.hash_st SHA2_256
let hash_256 output input input_len =
  [@inline_let]
  let output: lbuffer uint8 (Hacl.Hash.Definitions.hash_len SHA2_256) = output in
  let ib = ntup1 input in
  let rb = ntup1 output in
  let h0 = ST.get() in
  loc_multi1 rb;
  hash #SHA2_256 #M32 sha256_init sha256_update_nblocks sha256_update_last sha256_finish rb input_len ib;
  let h1 = ST.get() in
  Hacl.Spec.SHA2.Equiv.hash_agile_lemma #SHA2_256 #M32 (v input_len) (as_seq_multi h0 ib);
  assert ((as_seq_multi h1 rb).(|0|) == as_seq h1 output)

// SHA2-224
// --------

inline_for_extraction noextract
let alloca_224 = F.alloca hacl_sha2_224 () (state_224.s ()) (G.erased unit)
let malloc_224 = F.malloc hacl_sha2_224 () (state_224.s ()) (G.erased unit)
let reset_224 = F.reset hacl_sha2_224 (G.hide ()) (state_224.s ()) (G.erased unit)
// We assume verified clients will rely on Spec.SHA2.Lemmas to prove that update_224 has the same effect as update_256.
let update_224: F.update_st hacl_sha2_256 (G.hide ()) (state_256.s ()) (G.erased unit) = fun state input input_len -> update_224_256 state input input_len

[@@ Comment
"Write the resulting hash into `output`, an array of 28 bytes. The state remains
valid after a call to `digest_224`, meaning the user may feed more data into
the hash via `update_224`."]
let digest_224 = F.digest hacl_sha2_224 () (state_224.s ()) (G.erased unit)
let free_224: F.free_st hacl_sha2_256 (G.hide ()) (state_256.s ()) (G.erased unit) = fun state -> free_256 state

[@@ Comment
"Hash `input`, of len `input_len`, into `output`, an array of 28 bytes."]
val hash_224: Hacl.Hash.Definitions.hash_st SHA2_224
let hash_224 output input input_len =
  [@inline_let]
  let output: lbuffer uint8 (Hacl.Hash.Definitions.hash_len SHA2_224) = output in
  let ib = ntup1 input in
  let rb = ntup1 output in
  let h0 = ST.get() in
  loc_multi1 rb;
  hash #SHA2_224 #M32 sha224_init sha224_update_nblocks sha224_update_last sha224_finish rb input_len ib;
  let h1 = ST.get() in
  Hacl.Spec.SHA2.Equiv.hash_agile_lemma #SHA2_224 #M32 (v input_len) (as_seq_multi h0 ib);
  assert ((as_seq_multi h1 rb).(|0|) == as_seq h1 output)

// SHA2-512
// --------

inline_for_extraction noextract
let alloca_512 = F.alloca hacl_sha2_512 () (state_512.s ()) (G.erased unit)
let malloc_512 = F.malloc hacl_sha2_512 () (state_512.s ()) (G.erased unit)

[@@ Comment
"Copies the state passed as argument into a newly allocated state (deep copy).
The state is to be freed by calling `free_512`. Cloning the state this way is
useful, for instance, if your control-flow diverges and you need to feed
more (different) data into the hash in each branch."]
let copy_512 = F.copy hacl_sha2_512 () (state_512.s ()) (G.erased unit)

let reset_512 = F.reset hacl_sha2_512 (G.hide ()) (state_512.s ()) (G.erased unit)

[@@ CInline ]
private
let update_384_512 = F.update hacl_sha2_512 (G.hide ()) (state_512.s ()) (G.erased unit)
[@@ Comment
"Feed an arbitrary amount of data into the hash. This function returns 0 for
success, or 1 if the combined length of all of the data passed to `update_512`
(since the last call to `reset_512`) exceeds 2^125-1 bytes.

This function is identical to the update function for SHA2_384.";
]
let update_512: F.update_st hacl_sha2_512 (G.hide ()) (state_512.s ()) (G.erased unit) = fun state input input_len -> update_384_512 state input input_len

[@@ Comment
"Write the resulting hash into `output`, an array of 64 bytes. The state remains
valid after a call to `digest_512`, meaning the user may feed more data into
the hash via `update_512`. (The digest_512 function operates on an internal copy of
the state and therefore does not invalidate the client-held state `p`.)"]
let digest_512 = F.digest hacl_sha2_512 () (state_512.s ()) (G.erased unit)

[@@ Comment
"Free a state allocated with `malloc_512`.

This function is identical to the free function for SHA2_384.";
]
let free_512 = F.free hacl_sha2_512 (G.hide ()) (state_512.s ()) (G.erased unit)

[@@ Comment
"Hash `input`, of len `input_len`, into `output`, an array of 64 bytes."]
val hash_512: Hacl.Hash.Definitions.hash_st SHA2_512
let hash_512 output input input_len =
  [@inline_let]
  let output: lbuffer uint8 (Hacl.Hash.Definitions.hash_len SHA2_512) = output in
  let ib = ntup1 input in
  let rb = ntup1 output in
  let h0 = ST.get() in
  loc_multi1 rb;
  hash #SHA2_512 #M32 sha512_init sha512_update_nblocks sha512_update_last sha512_finish rb input_len ib;
  let h1 = ST.get() in
  Hacl.Spec.SHA2.Equiv.hash_agile_lemma #SHA2_512 #M32 (v input_len) (as_seq_multi h0 ib);
  assert ((as_seq_multi h1 rb).(|0|) == as_seq h1 output)

// SHA2-384
// --------

inline_for_extraction noextract
let alloca_384 = F.alloca hacl_sha2_384 () (state_384.s ()) (G.erased unit)
let malloc_384 = F.malloc hacl_sha2_384 () (state_384.s ()) (G.erased unit)
let reset_384 = F.reset hacl_sha2_384 (G.hide ()) (state_384.s ()) (G.erased unit)
let update_384: F.update_st hacl_sha2_512 (G.hide ()) (state_512.s ()) (G.erased unit) = fun state input input_len -> update_384_512 state input input_len

[@@ Comment
"Write the resulting hash into `output`, an array of 48 bytes. The state remains
valid after a call to `digest_384`, meaning the user may feed more data into
the hash via `update_384`."]
let digest_384 = F.digest hacl_sha2_384 () (state_384.s ()) (G.erased unit)

let free_384: F.free_st hacl_sha2_512 (G.hide ()) (state_512.s ()) (G.erased unit) = fun state -> free_512 state

[@@ Comment
"Hash `input`, of len `input_len`, into `output`, an array of 48 bytes."]
val hash_384: Hacl.Hash.Definitions.hash_st SHA2_384
let hash_384 output input input_len =
  [@inline_let]
  let output: lbuffer uint8 (Hacl.Hash.Definitions.hash_len SHA2_384) = output in
  let ib = ntup1 input in
  let rb = ntup1 output in
  let h0 = ST.get() in
  loc_multi1 rb;
  hash #SHA2_384 #M32 sha384_init sha384_update_nblocks sha384_update_last sha384_finish rb input_len ib;
  let h1 = ST.get() in
  Hacl.Spec.SHA2.Equiv.hash_agile_lemma #SHA2_384 #M32 (v input_len) (as_seq_multi h0 ib);
  assert ((as_seq_multi h1 rb).(|0|) == as_seq h1 output)
