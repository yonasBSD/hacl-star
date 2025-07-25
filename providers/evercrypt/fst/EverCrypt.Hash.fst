module EverCrypt.Hash

#set-options "--fuel 0 --ifuel 0 --z3rlimit 100"

open FStar.HyperStack.ST

module B = LowStar.Buffer
module IB = LowStar.ImmutableBuffer
module HS = FStar.HyperStack
module ST = FStar.HyperStack.ST

module AC = EverCrypt.AutoConfig2

open LowStar.BufferOps
open FStar.Integers
open C.Failure


// Allow *just* the alg type to be inverted, so that the entire module can run
// with ifuel 0
let _: squash (inversion alg) = allow_inversion alg

let string_of_alg =
  let open C.String in function
  | MD5 -> !$"MD5"
  | SHA1 -> !$"SHA1"
  | SHA2_224 -> !$"SHA2_224"
  | SHA2_256 -> !$"SHA2_256"
  | SHA2_384 -> !$"SHA2_384"
  | SHA2_512 -> !$"SHA2_512"
  | SHA3_224 -> !$"SHA3_224"
  | SHA3_256 -> !$"SHA3_256"
  | SHA3_384 -> !$"SHA3_384"
  | SHA3_512 -> !$"SHA3_512"
  | Shake128 -> !$"Shake128"
  | Shake256 -> !$"Shake256"
  | Blake2S -> !$"Blake2S"
  | Blake2B -> !$"Blake2B"

let uint32_p = B.buffer uint_32
let uint64_p = B.buffer uint_64

let is_valid_impl (i: impl) =
  let open Hacl.Impl.Blake2.Core in
  match i with
  | (| MD5, () |)
  | (| SHA1, () |)
  | (| SHA2_224, () |)
  | (| SHA2_256, () |)
  | (| SHA2_384, () |)
  | (| SHA2_512, () |)
  | (| SHA3_224, () |)
  | (| SHA3_256, () |)
  | (| SHA3_384, () |)
  | (| SHA3_512, () |)
  | (| Blake2S, M32 |)
  | (| Blake2S, M128 |)
  | (| Blake2B, M32 |)
  | (| Blake2B, M256 |) -> true
  | _ -> false

let impl = i:impl { is_valid_impl i }

inline_for_extraction noextract
let md5: impl = (| MD5, () |)
inline_for_extraction noextract
let sha1: impl = (| SHA1, () |)
inline_for_extraction noextract
let sha2_224: impl = (| SHA2_224, () |)
inline_for_extraction noextract
let sha2_256: impl = (| SHA2_256, () |)
inline_for_extraction noextract
let sha2_384: impl = (| SHA2_384, () |)
inline_for_extraction noextract
let sha2_512: impl = (| SHA2_512, () |)
inline_for_extraction noextract
let sha3_224: impl = (| SHA3_224, () |)
inline_for_extraction noextract
let sha3_256: impl = (| SHA3_256, () |)
inline_for_extraction noextract
let sha3_384: impl = (| SHA3_384, () |)
inline_for_extraction noextract
let sha3_512: impl = (| SHA3_512, () |)
inline_for_extraction noextract
let blake2s_32: impl = (| Blake2S, Hacl.Impl.Blake2.Core.M32 |)
inline_for_extraction noextract
let blake2s_128: impl = (| Blake2S, Hacl.Impl.Blake2.Core.M128 |)
inline_for_extraction noextract
let blake2b_32: impl = (| Blake2B, Hacl.Impl.Blake2.Core.M32 |)
inline_for_extraction noextract
let blake2b_256: impl = (| Blake2B, Hacl.Impl.Blake2.Core.M256 |)

inline_for_extraction noextract
let alg_of_impl (i: impl { is_valid_impl i }): alg = dfst i

// JP: This is a slightly more complicated case than for AEAD... for AEAD,
//   `state_s a = i & kv a & buffer uint8`
// because no matter the /implementation/, the resulting C type for the key is
// always a pointer to bytes. Here, that's no longer true because of Blake2, so
// we need to be a little more verbose.
noeq
type state_s: alg -> Type0 =
| MD5_s: p:Hacl.Hash.Definitions.state (|MD5, ()|) -> state_s MD5
| SHA1_s: p:Hacl.Hash.Definitions.state (|SHA1, ()|) -> state_s SHA1
| SHA2_224_s: p:Hacl.Hash.Definitions.state (|SHA2_224, ()|) -> state_s SHA2_224
| SHA2_256_s: p:Hacl.Hash.Definitions.state (|SHA2_256, ()|) -> state_s SHA2_256
| SHA2_384_s: p:Hacl.Hash.Definitions.state (|SHA2_384, ()|) -> state_s SHA2_384
| SHA2_512_s: p:Hacl.Hash.Definitions.state (|SHA2_512, ()|) -> state_s SHA2_512
| SHA3_224_s: p:Hacl.Hash.Definitions.state (|SHA3_224, ()|) -> state_s SHA3_224
| SHA3_256_s: p:Hacl.Hash.Definitions.state (|SHA3_256, ()|) -> state_s SHA3_256
| SHA3_384_s: p:Hacl.Hash.Definitions.state (|SHA3_384, ()|) -> state_s SHA3_384
| SHA3_512_s: p:Hacl.Hash.Definitions.state (|SHA3_512, ()|) -> state_s SHA3_512
| Blake2S_s: p:Hacl.Hash.Definitions.state (|Blake2S, Hacl.Impl.Blake2.Core.M32|) -> state_s Blake2S
| Blake2S_128_s:
  _:squash (EverCrypt.TargetConfig.hacl_can_compile_vec128 /\
    EverCrypt.AutoConfig2.vec128_enabled) ->
  p:Hacl.Hash.Definitions.state (|Blake2S, Hacl.Impl.Blake2.Core.M128|) ->
  state_s Blake2S
| Blake2B_s: p:Hacl.Hash.Definitions.state (|Blake2B, Hacl.Impl.Blake2.Core.M32|) -> state_s Blake2B
| Blake2B_256_s:
  _:squash (EverCrypt.TargetConfig.hacl_can_compile_vec256 /\
    EverCrypt.AutoConfig2.vec256_enabled) ->
  p:Hacl.Hash.Definitions.state (|Blake2B, Hacl.Impl.Blake2.Core.M256|) -> state_s Blake2B

let invert_state_s (a: alg): Lemma
  (requires True)
  (ensures (inversion (state_s a)))
  [ SMTPat (state_s a) ]
=
  allow_inversion (state_s a)

[@@strict_on_arguments [1]]
inline_for_extraction
let impl_of_state #a (s: state_s a): i:impl { alg_of_impl i == a } =
  match s with
  | MD5_s _ -> md5
  | SHA1_s _ -> sha1
  | SHA2_224_s _ -> sha2_224
  | SHA2_256_s _ -> sha2_256
  | SHA2_384_s _ -> sha2_384
  | SHA2_512_s _ -> sha2_512
  | SHA3_224_s _ -> sha3_224
  | SHA3_256_s _ -> sha3_256
  | SHA3_384_s _ -> sha3_384
  | SHA3_512_s _ -> sha3_512
  | Blake2S_s _ -> blake2s_32
  | Blake2S_128_s _ _ -> blake2s_128
  | Blake2B_s _ -> blake2b_32
  | Blake2B_256_s _ _ -> blake2b_256

// In state_s, the data type already captures what implementation we have... three
// design choices here:
// - turn state_s into a dependent pair of G.erased impl & (SHA2_s | SHA3_s |
//   ...) so as not to repeat redundant information at run-time
// - hope that we can get away with returning dependent pairs only when needed.
// We're going for a third one in this module, which is more lightweight.
[@@strict_on_arguments [1]]
inline_for_extraction
let p #a (s: state_s a): Hacl.Hash.Definitions.state (impl_of_state s) =
  match s with
  | MD5_s p -> p
  | SHA1_s p -> p
  | SHA2_224_s p -> p
  | SHA2_256_s p -> p
  | SHA2_384_s p -> p
  | SHA2_512_s p -> p
  | SHA3_224_s p -> p
  | SHA3_256_s p -> p
  | SHA3_384_s p -> p
  | SHA3_512_s p -> p
  | Blake2S_s p -> p
  | Blake2S_128_s _ p -> p
  | Blake2B_s p -> p
  | Blake2B_256_s _ p -> p

let freeable_s #a s = B.freeable (p #a s)

let footprint_s #a (s: state_s a) =
  B.loc_addr_of_buffer (p s)

let invariant_s #a (s: state_s a) h =
  B.live h (p s)

let repr #a s h: GTot _ =
  let s = B.get h s 0 in
  as_seq h (p s)

let alg_of_state a s =
  let open LowStar.BufferOps in
  match !*s with
  | MD5_s _ -> MD5
  | SHA1_s _ -> SHA1
  | SHA2_224_s _ -> SHA2_224
  | SHA2_256_s _ -> SHA2_256
  | SHA2_384_s _ -> SHA2_384
  | SHA2_512_s _ -> SHA2_512
  | SHA3_224_s _ -> SHA3_224
  | SHA3_256_s _ -> SHA3_256
  | SHA3_384_s _ -> SHA3_384
  | SHA3_512_s _ -> SHA3_512
  | Blake2S_s _ -> Blake2S
  | Blake2S_128_s _ _ -> Blake2S
  | Blake2B_s _ -> Blake2B
  | Blake2B_256_s _ _ -> Blake2B

let repr_eq (#a:alg) (r1 r2: Spec.Hash.Definitions.words_state a) =
  Seq.equal r1 r2

let fresh_is_disjoint l1 l2 h0 h1 = ()

let invariant_loc_in_footprint #a s m = ()

let frame_invariant #a l s h0 h1 =
  let state = B.deref h0 s in
  assert (repr_eq (repr s h0) (repr s h1))

inline_for_extraction noextract
[@@strict_on_arguments [0]]
let alloca a =
  let s: state_s a =
    match a with
    | MD5 -> MD5_s (B.alloca 0ul 4ul)
    | SHA1 -> SHA1_s (B.alloca 0ul 5ul)
    | SHA2_224 -> SHA2_224_s (B.alloca 0ul 8ul)
    | SHA2_256 -> SHA2_256_s (B.alloca 0ul 8ul)
    | SHA2_384 -> SHA2_384_s (B.alloca 0UL 8ul)
    | SHA2_512 -> SHA2_512_s (B.alloca 0UL 8ul)
    | SHA3_224 -> SHA3_224_s (B.alloca 0UL 25ul)
    | SHA3_256 -> SHA3_256_s (B.alloca 0UL 25ul)
    | SHA3_384 -> SHA3_384_s (B.alloca 0UL 25ul)
    | SHA3_512 -> SHA3_512_s (B.alloca 0UL 25ul)
    | Blake2S ->
        if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
          let vec128 = EverCrypt.AutoConfig2.has_vec128 () in
          if vec128 then
            let open Hacl.Impl.Blake2.Core in
            [@inline_let] let i: impl = (| Blake2S , M128 |) in
            Blake2S_128_s () (B.alloca (zero_element Spec.Blake2.Blake2S M128) (impl_state_len i))
          else
            Blake2S_s (B.alloca 0ul 16ul)
        else
          Blake2S_s (B.alloca 0ul 16ul)
    | Blake2B ->
        if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
          let vec256 = EverCrypt.AutoConfig2.has_vec256 () in
          if vec256 then
            let open Hacl.Impl.Blake2.Core in
            [@inline_let] let i: impl = (| Blake2B , M256 |) in
            Blake2B_256_s () (B.alloca (zero_element Spec.Blake2.Blake2B M256) (impl_state_len i))
          else
            Blake2B_s (B.alloca 0uL 16ul)
        else
          Blake2B_s (B.alloca 0uL 16ul)
  in
  B.alloca s 1ul

inline_for_extraction noextract
let scalar_impl_of_alg (a: alg): impl =
  match a with
  | MD5 -> (| MD5, () |)
  | SHA1 -> (| SHA1, () |)
  | SHA2_224 -> (| SHA2_224, () |)
  | SHA2_256 -> (| SHA2_256, () |)
  | SHA2_384 -> (| SHA2_384, () |)
  | SHA2_512 -> (| SHA2_512, () |)
  | SHA3_224 -> (| SHA3_224, () |)
  | SHA3_256 -> (| SHA3_256, () |)
  | SHA3_384 -> (| SHA3_384, () |)
  | SHA3_512 -> (| SHA3_512, () |)
  | Blake2S -> (| Blake2S, Hacl.Impl.Blake2.Core.M32 |)
  | Blake2B -> (| Blake2B, Hacl.Impl.Blake2.Core.M32 |)

inline_for_extraction noextract
val malloc_helper (#a: alg) (r: HS.rid) (init: impl_word (scalar_impl_of_alg a))
  (mk: (b:Hacl.Hash.Definitions.state (scalar_impl_of_alg a)) -> Stack (state_s a)
    (requires fun h0 -> True)
    (ensures fun h0 s h1 -> impl_of_state s == scalar_impl_of_alg a /\ h0 == h1 /\ p s == b)
  ):
  FStar.HyperStack.ST.ST (B.buffer (state_s a))
  (requires (fun _ ->
    HyperStack.ST.is_eternal_region r))
  (ensures (fun h0 s h1 ->
    if B.g_is_null s then
      B.(modifies loc_none h0 h1)
    else
      B.length s == 1 /\
      invariant s h1 /\
      M.(modifies loc_none h0 h1) /\
      B.fresh_loc (footprint s h1) h0 h1 /\
      M.(loc_includes (loc_region_only true r) (footprint s h1)) /\
      freeable h1 s))

let malloc_helper #a r init mk =
  let open Hacl.Streaming.Interface in
  let h0 = ST.get () in
  let s = fallible_malloc r init (impl_state_len (scalar_impl_of_alg a)) in
    if B.is_null s then
    B.null
  else
    let s: Hacl.Hash.Definitions.state (scalar_impl_of_alg a) = s in
    let st = fallible_malloc r (mk s) 1ul in
    if B.is_null st then (
      B.free s;
      let h1 = ST.get () in
      B.(modifies_only_not_unused_in loc_none h0 h1);
      B.null
    ) else
      let h1 = ST.get () in
      st

val malloc_: a:alg -> r:HS.rid -> ST (B.buffer (state_s a))
  (requires (fun _ ->
    HyperStack.ST.is_eternal_region r))
  (ensures (fun h0 s h1 ->
    if B.g_is_null s then
      B.(modifies loc_none h0 h1)
    else
      B.length s == 1 /\
      invariant s h1 /\
      M.(modifies loc_none h0 h1) /\
      B.fresh_loc (footprint s h1) h0 h1 /\
      M.(loc_includes (loc_region_only true r) (footprint s h1)) /\
      freeable h1 s))

let malloc_ a r =
  let h0 = ST.get () in
  let open Hacl.Streaming.Interface in
  // NOTE: the helper was a PAIN to write but hopefully it'll make maintenance better
  match a with
  | MD5 -> malloc_helper r 0ul (fun x -> MD5_s x)
  | SHA1 -> malloc_helper r 0ul (fun x -> SHA1_s x)
  | SHA2_224 -> malloc_helper r 0ul (fun x -> SHA2_224_s x)
  | SHA2_256 -> malloc_helper r 0ul (fun x -> SHA2_256_s x)
  | SHA2_384 -> malloc_helper r 0UL (fun x -> SHA2_384_s x)
  | SHA2_512 -> malloc_helper r 0UL (fun x -> SHA2_512_s x)
  | SHA3_224 -> malloc_helper r 0UL (fun x -> SHA3_224_s x)
  | SHA3_256 -> malloc_helper r 0UL (fun x -> SHA3_256_s x)
  | SHA3_384 -> malloc_helper r 0UL (fun x -> SHA3_384_s x)
  | SHA3_512 -> malloc_helper r 0UL (fun x -> SHA3_512_s x)
  | Blake2S ->
      // As usual, to prevent linking errors (missing symbols) on systems that
      // do not have this implementation available.
      if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
        let vec128 = EverCrypt.AutoConfig2.has_vec128 () in
        if vec128 then
          let s = Hacl.Blake2s_128.malloc_internal_state_with_key r in
          if B.is_null s then
            B.null
          else
            let st = fallible_malloc r (Blake2S_128_s () s) 1ul in
            if B.is_null st then (
              B.free s;
              let h1 = ST.get () in
              B.(modifies_only_not_unused_in loc_none h0 h1);
              B.null
            ) else
              st
        else
          malloc_helper r 0ul (fun x -> Blake2S_s x)
      else
        malloc_helper r 0ul (fun x -> Blake2S_s x)
  | Blake2B ->
      // As usual, to prevent linking errors (missing symbols) on systems that
      // do not have this implementation available.
      if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
        let vec256 = EverCrypt.AutoConfig2.has_vec256 () in
        if vec256 then
          let s = Hacl.Blake2b_256.malloc_internal_state_with_key r in
          if B.is_null s then
            B.null
          else
            let st = fallible_malloc r (Blake2B_256_s () s) 1ul in
            if B.is_null st then (
              B.free s;
              let h1 = ST.get () in
              B.(modifies_only_not_unused_in loc_none h0 h1);
              B.null
            ) else
              st
        else
          malloc_helper r 0UL (fun x -> Blake2B_s x)
      else
        malloc_helper r 0UL (fun x -> Blake2B_s x)

[@@strict_on_arguments [0]]
let create_in a r =
  let s = malloc_ a r in
  if B.is_null s then None else Some s

#push-options "--ifuel 1"

// NOTE: HACL* does not require suitable preconditions so the squashed proofs
// that we have the right CPU flags are useless. But it's good to demonstrate
// how to do it for future reference and/or future other implementations.
let init #a s =
  match !*s with
  | MD5_s p -> Hacl.Hash.MD5.init p
  | SHA1_s p -> Hacl.Hash.SHA1.init p
  | SHA2_224_s p -> Hacl.Hash.SHA2.init_224 p
  | SHA2_256_s p -> Hacl.Hash.SHA2.init_256 p
  | SHA2_384_s p -> Hacl.Hash.SHA2.init_384 p
  | SHA2_512_s p -> Hacl.Hash.SHA2.init_512 p
  | SHA3_224_s p -> Hacl.Hash.SHA3.init SHA3_224 p
  | SHA3_256_s p -> Hacl.Hash.SHA3.init SHA3_256 p
  | SHA3_384_s p -> Hacl.Hash.SHA3.init SHA3_384 p
  | SHA3_512_s p -> Hacl.Hash.SHA3.init SHA3_512 p
  | Blake2S_s p -> let _ = Hacl.Hash.Blake2s_32.init p in ()
  | Blake2S_128_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
        let _ = Hacl.Hash.Blake2s_128.init p in ()
        else LowStar.Ignore.ignore p
  | Blake2B_s p -> let _ = Hacl.Hash.Blake2b_32.init p in ()
  | Blake2B_256_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
        let _ = Hacl.Hash.Blake2b_256.init p in ()
      else LowStar.Ignore.ignore p
#pop-options

friend Vale.SHA.SHA_helpers

// Avoid a cross-compilation unit symbol visibility... duplicate locally.
let k224_256 =
  LowStar.ImmutableBuffer.igcmalloc_of_list HS.root Spec.SHA2.Constants.k224_256_l

#push-options "--ifuel 1"

// A new switch between HACL and Vale; can be used in place of Hacl.Hash.SHA2.update_256
// NOTE: this is an old-style switch where the CPU check is done on every call
// to update_multi... this is SUBOPTIMAL. I (JP) ported this module to use a
// proper concept of /implementation/, and for the Blake2 optimized variants,
// the state is now capable of keeping a squashed proof that the CPU supports
// what is needed...
// TODO: introduce SHA2_256_Vale in the state and test for CPU instructions only
// once, at state-creation time!
let update_multi_256 s ev blocks n =
  if EverCrypt.TargetConfig.hacl_can_compile_vale then begin
    let has_shaext = AC.has_shaext () in
    let has_sse = AC.has_sse () in
    if (has_shaext && has_sse) then begin
      let n = Int.Cast.Full.uint32_to_uint64 n in
      B.recall k224_256;
      IB.recall_contents k224_256 Spec.SHA2.Constants.k224_256;
      let h1 = ST.get () in
      IB.buffer_immutable_buffer_disjoint s k224_256 h1;
      let h2 = ST.get () in
      IB.buffer_immutable_buffer_disjoint blocks k224_256 h2;
      let res = Vale.Wrapper.X64.Sha.sha256_update s blocks n k224_256 in
      res
    end else
      Hacl.Hash.SHA2.update_multi_256 s () blocks n
  end else (
    LowStar.Ignore.ignore k224_256;
    Hacl.Hash.SHA2.update_multi_256 s () blocks n)

#pop-options

inline_for_extraction noextract
let update_multi_224 s ev blocks n =
  assert_norm (words_state SHA2_224 == words_state SHA2_256);
  let h0 = ST.get () in
  Spec.SHA2.Lemmas.update_multi_224_256 (B.as_seq h0 s) (B.as_seq h0 blocks);
  update_multi_256 s ev blocks n


#push-options "--ifuel 1"

let update_multi #a s prevlen blocks len =
  match !*s with
  | MD5_s p ->
      let n = len / block_len MD5 in
      Hacl.Hash.MD5.update_multi p () blocks n
  | SHA1_s p ->
      let n = len / block_len SHA1 in
      Hacl.Hash.SHA1.update_multi p () blocks n
  | SHA2_224_s p ->
      let n = len / block_len SHA2_224 in
      update_multi_224 p () blocks n
  | SHA2_256_s p ->
      let n = len / block_len SHA2_256 in
      update_multi_256 p () blocks n
  | SHA2_384_s p ->
      let n = len / block_len SHA2_384 in
      Hacl.Hash.SHA2.update_multi_384 p () blocks n
  | SHA2_512_s p ->
      let n = len / block_len SHA2_512 in
      Hacl.Hash.SHA2.update_multi_512 p () blocks n
  | SHA3_224_s p -> let n = len / block_len SHA3_224 in Hacl.Hash.SHA3.update_multi SHA3_224 p () blocks n
  | SHA3_256_s p -> let n = len / block_len SHA3_256 in Hacl.Hash.SHA3.update_multi SHA3_256 p () blocks n
  | SHA3_384_s p -> let n = len / block_len SHA3_384 in Hacl.Hash.SHA3.update_multi SHA3_384 p () blocks n
  | SHA3_512_s p -> let n = len / block_len SHA3_512 in Hacl.Hash.SHA3.update_multi SHA3_512 p () blocks n
  | Blake2S_s p ->
      let n = len / block_len Blake2S in
      let _ = Hacl.Hash.Blake2s_32.update_multi p prevlen blocks n in
      ()
  | Blake2S_128_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
        let n = len / block_len Blake2S in
        let _ = Hacl.Hash.Blake2s_128.update_multi p prevlen blocks n in
        ()
      else LowStar.Ignore.ignore p
  | Blake2B_s p ->
      [@inline_let] let prevlen = Int.Cast.Full.uint64_to_uint128 prevlen in
      let n = len / block_len Blake2B in
      let _ = Hacl.Hash.Blake2b_32.update_multi p prevlen blocks n in
      ()
  | Blake2B_256_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
        [@inline_let] let prevlen = Int.Cast.Full.uint64_to_uint128 prevlen in
        let n = len / block_len Blake2B in
        let _ = Hacl.Hash.Blake2b_256.update_multi p prevlen blocks n in
        ()
      else LowStar.Ignore.ignore p

#pop-options

let update_last #a s prev_len last last_len =
  [@inline_let] let cast = FStar.Int.Cast.Full.uint64_to_uint128 in
  match !*s with
  | MD5_s p ->
      Hacl.Hash.MD5.update_last p prev_len last last_len
  | SHA1_s p ->
      Hacl.Hash.SHA1.update_last p prev_len last last_len
  | SHA2_224_s p ->
      Hacl.Hash.SHA2.update_last_224 p prev_len last last_len
  | SHA2_256_s p ->
      Hacl.Hash.SHA2.update_last_256 p prev_len last last_len
  | SHA2_384_s p ->
      Hacl.Hash.SHA2.update_last_384 p (cast prev_len) last last_len
  | SHA2_512_s p ->
      Hacl.Hash.SHA2.update_last_512 p (cast prev_len) last last_len
  | SHA3_224_s p -> Hacl.Hash.SHA3.update_last SHA3_224 p () last last_len
  | SHA3_256_s p -> Hacl.Hash.SHA3.update_last SHA3_256 p () last last_len
  | SHA3_384_s p -> Hacl.Hash.SHA3.update_last SHA3_384 p () last last_len
  | SHA3_512_s p -> Hacl.Hash.SHA3.update_last SHA3_512 p () last last_len
  | Blake2S_s p ->
      Hacl.Hash.Blake2s_32.update_last p prev_len last last_len
  | Blake2S_128_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
        Hacl.Hash.Blake2s_128.update_last p prev_len last last_len
      else LowStar.Ignore.ignore p
  | Blake2B_s p ->
      Hacl.Hash.Blake2b_32.update_last p (cast prev_len) last last_len
  | Blake2B_256_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
        Hacl.Hash.Blake2b_256.update_last p (cast prev_len) last last_len
      else LowStar.Ignore.ignore p

// TODO: move to FStar.Math.Lemmas
val modulo_sub_lemma (a : int) (b : nat) (c : pos) :
  Lemma
  (requires (b < c /\ (a - b) % c = 0))
  (ensures (b = a % c))
let modulo_sub_lemma a b c =
  calc (==) {
    (a - b) % c;
  == { Math.Lemmas.lemma_mod_add_distr (-b) a c }
    ((a % c) - b) % c;
  };
  assert(- c < (a % c) - b);
  assert((a % c) - b < c);
  Math.Lemmas.euclidean_division_definition ((a % c) - b) c;
  assert(a % c - b = ((a % c - b) / c) * c);
  assert(1 * c = c);
  assert((-1) * c = - c);
  let d = (a % c - b) / c in
  if 1 <= d then
    begin
    Math.Lemmas.lemma_mult_le_right c 1 d;
    assert(d * c >= 1 * c);
    assert(False)
    end;
  if d <= -1 then
    begin
    Math.Lemmas.lemma_mult_le_right c d (-1);
    assert(d * c <= (-1) * c);
    assert(d * c <= - c);
    assert(False)
    end;
  assert(d = 0);
  assert(d * c = 0);
  assert(a % c - b = 0);
  assert(a % c = b)

#push-options "--ifuel 1"

let finish #a s dst =
  match !*s with
  | MD5_s p -> Hacl.Hash.MD5.finish p dst
  | SHA1_s p -> Hacl.Hash.SHA1.finish p dst
  | SHA2_224_s p -> Hacl.Hash.SHA2.finish_224 p dst
  | SHA2_256_s p -> Hacl.Hash.SHA2.finish_256 p dst
  | SHA2_384_s p -> Hacl.Hash.SHA2.finish_384 p dst
  | SHA2_512_s p -> Hacl.Hash.SHA2.finish_512 p dst
  | SHA3_224_s p -> Hacl.Hash.SHA3.finish SHA3_224 p dst
  | SHA3_256_s p -> Hacl.Hash.SHA3.finish SHA3_256 p dst
  | SHA3_384_s p -> Hacl.Hash.SHA3.finish SHA3_384 p dst
  | SHA3_512_s p -> Hacl.Hash.SHA3.finish SHA3_512 p dst
  | Blake2S_s p -> Hacl.Hash.Blake2s_32.finish p dst
  | Blake2S_128_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
        Hacl.Hash.Blake2s_128.finish p dst
      else LowStar.Ignore.ignore p
  | Blake2B_s p ->
      Hacl.Hash.Blake2b_32.finish p dst
  | Blake2B_256_s _ p ->
      if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
        Hacl.Hash.Blake2b_256.finish p dst
      else LowStar.Ignore.ignore p

#pop-options

let free_ #ea s =
  begin match !*s with
  | MD5_s p -> B.free p
  | SHA1_s p -> B.free p
  | SHA2_224_s p -> B.free p
  | SHA2_256_s p -> B.free p
  | SHA2_384_s p -> B.free p
  | SHA2_512_s p -> B.free p
  | SHA3_224_s p -> B.free p
  | SHA3_256_s p -> B.free p
  | SHA3_384_s p -> B.free p
  | SHA3_512_s p -> B.free p
  | Blake2S_s p -> B.free p
  | Blake2S_128_s _ p -> B.free p
  | Blake2B_s p -> B.free p
  | Blake2B_256_s _ p -> B.free p
  end;
  B.free s

#push-options "--ifuel 1"

let copy #a s_src s_dst =
  match !*s_src with
  | MD5_s p_src ->
      [@inline_let]
      let s_dst: state MD5 = s_dst in
      let p_dst = MD5_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 4ul
  | SHA1_s p_src ->
      [@inline_let]
      let s_dst: state SHA1 = s_dst in
      let p_dst = SHA1_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 5ul
  | SHA2_224_s p_src ->
      [@inline_let]
      let s_dst: state SHA2_224 = s_dst in
      let p_dst = SHA2_224_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 8ul
  | SHA2_256_s p_src ->
      [@inline_let]
      let s_dst: state SHA2_256 = s_dst in
      let p_dst = SHA2_256_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 8ul
  | SHA2_384_s p_src ->
      [@inline_let]
      let s_dst: state SHA2_384 = s_dst in
      let p_dst = SHA2_384_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 8ul
  | SHA2_512_s p_src ->
      [@inline_let]
      let s_dst: state SHA2_512 = s_dst in
      let p_dst = SHA2_512_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 8ul
  | SHA3_224_s p_src ->
      [@inline_let] let s_dst: state SHA3_224 = s_dst in
      let p_dst = SHA3_224_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 25ul
  | SHA3_256_s p_src ->
      [@inline_let] let s_dst: state SHA3_256 = s_dst in
      let p_dst = SHA3_256_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 25ul
  | SHA3_384_s p_src ->
      [@inline_let] let s_dst: state SHA3_384 = s_dst in
      let p_dst = SHA3_384_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 25ul
  | SHA3_512_s p_src ->
      [@inline_let] let s_dst: state SHA3_512 = s_dst in
      let p_dst = SHA3_512_s?.p !*s_dst in
      B.blit p_src 0ul p_dst 0ul 25ul
  | Blake2S_s p_src ->
      begin match !*s_dst with
      | Blake2S_s p_dst ->
          [@inline_let]
          let s_dst: state Blake2S = s_dst in
          B.blit p_src 0ul p_dst 0ul 16ul
      | Blake2S_128_s _ p_dst ->
          if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
            [@inline_let]
            let s_dst: state Blake2S = s_dst in
            Hacl.Blake2s_128.load_state128s_from_state32 p_dst p_src
          else LowStar.Ignore.ignore p_dst
      end
  | Blake2B_s p_src ->
      begin match !*s_dst with
      | Blake2B_s p_dst ->
          [@inline_let]
          let s_dst: state Blake2B = s_dst in
          B.blit p_src 0ul p_dst 0ul 16ul
      | Blake2B_256_s _ p_dst ->
          if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
            [@inline_let]
            let s_dst: state Blake2B = s_dst in
            Hacl.Blake2b_256.load_state256b_from_state32 p_dst p_src
          else LowStar.Ignore.ignore p_dst
      end
  | Blake2S_128_s _ p_src ->
      begin match !*s_dst with
      | Blake2S_128_s _ p_dst ->
          [@inline_let]
          let s_dst: state Blake2S = s_dst in
          B.blit p_src 0ul p_dst 0ul 4ul
      | Blake2S_s p_dst ->
          if EverCrypt.TargetConfig.hacl_can_compile_vec128 then
            [@inline_let]
            let s_dst: state Blake2S = s_dst in
            Hacl.Blake2s_128.store_state128s_to_state32 p_dst p_src
          else LowStar.Ignore.ignore p_dst
      end
  | Blake2B_256_s _ p_src ->
      begin match !*s_dst with
      | Blake2B_256_s _ p_dst ->
          [@inline_let]
          let s_dst: state Blake2B = s_dst in
          B.blit p_src 0ul p_dst 0ul 4ul
      | Blake2B_s p_dst ->
          if EverCrypt.TargetConfig.hacl_can_compile_vec256 then
            [@inline_let]
            let s_dst: state Blake2B = s_dst in
            Hacl.Blake2b_256.store_state256b_to_state32 p_dst p_src
          else LowStar.Ignore.ignore p_dst
      end

#pop-options
