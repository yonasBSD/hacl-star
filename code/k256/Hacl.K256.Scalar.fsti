module Hacl.K256.Scalar

open FStar.HyperStack
open FStar.HyperStack.ST
open FStar.Mul

open Lib.IntTypes
open Lib.Buffer

module LSeq = Lib.Sequence
module BSeq = Lib.ByteSequence

module S = Spec.K256
module SG = Hacl.Spec.K256.GLV

module BD = Hacl.Bignum.Definitions

#set-options "--z3rlimit 50 --fuel 0 --ifuel 0"


inline_for_extraction noextract
let qnlimb = 4ul

inline_for_extraction noextract
let qelem = lbuffer uint64 qnlimb

noextract
let qas_nat (h:mem) (e:qelem) : GTot nat = BD.bn_v #U64 #qnlimb h e

noextract
let qeval (h:mem) (e:qelem) : GTot S.qelem = qas_nat h e % S.q

noextract
let qe_lt_q (h:mem) (e:qelem) = qas_nat h e < S.q


inline_for_extraction noextract
let qelem4 = uint64 & uint64 & uint64 & uint64

noextract
let qas_nat4 (f:qelem4) =
  let (f0, f1, f2, f3) = f in
  v f0 + v f1 * pow2 64 + v f2 * pow2 128 + v f3 * pow2 192


inline_for_extraction noextract
val make_u64_4 (out:qelem) (f:qelem4) : Stack unit
  (requires fun h -> live h out)
  (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\
    qas_nat h1 out == qas_nat4 f /\
    (let (f0,f1,f2,f3) = f in as_seq h1 out == LSeq.create4 f0 f1 f2 f3))


inline_for_extraction noextract
val make_order_k256: unit -> Pure qelem4
  (requires True)
  (ensures  fun r -> qas_nat4 r = S.q)


inline_for_extraction noextract
val create_qelem: unit -> StackInline qelem
  (requires fun h -> True)
  (ensures  fun h0 f h1 ->
    stack_allocated f h0 h1 (LSeq.create (v qnlimb) (u64 0)) /\
    qas_nat h1 f == 0)


inline_for_extraction noextract
val create_one: unit -> StackInline qelem
  (requires fun h -> True)
  (ensures  fun h0 f h1 ->
    stack_allocated f h0 h1 (LSeq.create4 (u64 1) (u64 0) (u64 0) (u64 0)) /\
    qas_nat h1 f = 1)


val is_qelem_zero (f:qelem) : Stack uint64
  (requires fun h -> live h f)
  (ensures  fun h0 m h1 -> modifies0 h0 h1 /\
    (v m = 0 \/ v m = ones_v U64) /\
    v m == (if qas_nat h0 f = 0 then ones_v U64 else 0))


val is_qelem_zero_vartime (f:qelem) : Stack bool
  (requires fun h -> live h f)
  (ensures  fun h0 m h1 -> modifies0 h0 h1 /\
    m == (qas_nat h0 f = 0))


val is_qelem_eq_vartime (f1 f2:qelem) : Stack bool
  (requires fun h ->
    live h f1 /\ live h f2 /\ qe_lt_q h f1 /\ qe_lt_q h f2)
  (ensures  fun h0 m h1 -> modifies0 h0 h1 /\
    m == (qas_nat h0 f1 = qas_nat h0 f2))


inline_for_extraction noextract
val load_qelem: f:qelem -> b:lbuffer uint8 32ul -> Stack unit
  (requires fun h ->
    live h f /\ live h b /\ disjoint f b)
  (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1 /\
    qas_nat h1 f == BSeq.nat_from_bytes_be (as_seq h0 b))


val load_qelem_check: f:qelem -> b:lbuffer uint8 32ul -> Stack uint64
  (requires fun h ->
    live h f /\ live h b /\ disjoint f b)
  (ensures  fun h0 m h1 -> modifies (loc f) h0 h1 /\
   (let b_nat = BSeq.nat_from_bytes_be (as_seq h0 b) in
    qas_nat h1 f == b_nat /\ (v m = ones_v U64 \/ v m = 0) /\
    (v m = ones_v U64) = (0 < b_nat && b_nat < S.q)))


inline_for_extraction noextract
val load_qelem_conditional: res:qelem -> b:lbuffer uint8 32ul -> Stack uint64
  (requires fun h ->
    live h res /\ live h b /\ disjoint res b)
  (ensures fun h0 m h1 -> modifies (loc res) h0 h1 /\
   (let b_nat = BSeq.nat_from_bytes_be (as_seq h0 b) in
    let is_b_valid = 0 < b_nat && b_nat < S.q in
    (v m = ones_v U64 \/ v m = 0) /\ (v m = ones_v U64) = is_b_valid /\
    qas_nat h1 res == (if is_b_valid then b_nat else 1)))


val load_qelem_vartime: f:qelem -> b:lbuffer uint8 32ul -> Stack bool
  (requires fun h ->
    live h f /\ live h b /\ disjoint f b)
  (ensures  fun h0 m h1 -> modifies (loc f) h0 h1 /\
   (let b_nat = BSeq.nat_from_bytes_be (as_seq h0 b) in
    qas_nat h1 f == b_nat /\ m = (0 < b_nat && b_nat < S.q)))


val load_qelem_modq: f:qelem -> b:lbuffer uint8 32ul -> Stack unit
  (requires fun h ->
    live h f /\ live h b /\ disjoint f b)
  (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1 /\
    qas_nat h1 f == BSeq.nat_from_bytes_be (as_seq h0 b) % S.q /\
    qe_lt_q h1 f)


val store_qelem: b:lbuffer uint8 32ul -> f:qelem -> Stack unit
  (requires fun h ->
    live h b /\ live h f /\ disjoint f b /\
    qe_lt_q h f)
  (ensures  fun h0 _ h1 -> modifies (loc b) h0 h1 /\
    as_seq h1 b == BSeq.nat_to_bytes_be 32 (qas_nat h0 f))


val qadd (out f1 f2: qelem) : Stack unit
  (requires fun h ->
    live h out /\ live h f1 /\ live h f2 /\
    eq_or_disjoint out f1 /\ eq_or_disjoint out f2 /\ eq_or_disjoint f1 f2 /\
    qe_lt_q h f1 /\ qe_lt_q h f2)
  (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\
    qas_nat h1 out == S.qadd (qas_nat h0 f1) (qas_nat h0 f2) /\
    qe_lt_q h1 out)


val qmul (out f1 f2: qelem) : Stack unit
  (requires fun h ->
    live h out /\ live h f1 /\ live h f2 /\
    eq_or_disjoint out f1 /\ eq_or_disjoint out f2 /\ eq_or_disjoint f1 f2 /\
    qe_lt_q h f1 /\ qe_lt_q h f2)
  (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\
    qas_nat h1 out == S.qmul (qas_nat h0 f1) (qas_nat h0 f2) /\
    qe_lt_q h1 out)


val qsqr (out f: qelem) : Stack unit
  (requires fun h ->
    live h out /\ live h f /\ eq_or_disjoint out f /\
    qe_lt_q h f)
  (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\
    qas_nat h1 out == S.qmul (qas_nat h0 f) (qas_nat h0 f) /\
    qe_lt_q h1 out)


val qnegate_conditional_vartime (f:qelem) (is_negate:bool) : Stack unit
  (requires fun h -> live h f /\ qe_lt_q h f)
  (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1 /\ qe_lt_q h1 f /\
    qas_nat h1 f == (if is_negate then (S.q - qas_nat h0 f) % S.q else qas_nat h0 f))


val is_qelem_le_q_halved_vartime: f:qelem -> Stack bool
  (requires fun h -> live h f)
  (ensures  fun h0 b h1 -> modifies0 h0 h1 /\
    b == (qas_nat h0 f <= S.q / 2))


inline_for_extraction noextract
val is_qelem_lt_pow2_128_vartime: f:qelem -> Stack bool
  (requires fun h -> live h f)
  (ensures  fun h0 b h1 -> modifies0 h0 h1 /\
    b == (qas_nat h0 f < pow2 128))


val qmul_shift_384 (res a b: qelem) : Stack unit
  (requires fun h ->
    live h a /\ live h b /\ live h res /\
    eq_or_disjoint a b /\ eq_or_disjoint a res /\ eq_or_disjoint b res /\
    qas_nat h a < S.q /\ qas_nat h b < S.q)
  (ensures  fun h0 _ h1 -> modifies (loc res) h0 h1 /\
    qas_nat h1 res < S.q /\
    qas_nat h1 res == SG.qmul_shift_384 (qas_nat h0 a) (qas_nat h0 b))
