/* MIT License
 *
 * Copyright (c) 2016-2022 INRIA, CMU and Microsoft Corporation
 * Copyright (c) 2022-2023 HACL* Contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#include "Hacl_Frodo64.h"

#include "Hacl_Hash_SHA3.h"
#include "internal/Hacl_Spec.h"
#include "internal/Hacl_Frodo_KEM.h"
#include "lib_memzero0.h"

/*
 this variant is used only for testing purposes!
 */


uint32_t Hacl_Frodo64_crypto_bytes = 16U;

uint32_t Hacl_Frodo64_crypto_publickeybytes = 976U;

uint32_t Hacl_Frodo64_crypto_secretkeybytes = 2032U;

uint32_t Hacl_Frodo64_crypto_ciphertextbytes = 1080U;

uint32_t Hacl_Frodo64_crypto_kem_keypair(uint8_t *pk, uint8_t *sk)
{
  uint8_t coins[48U] = { 0U };
  randombytes_(48U, coins);
  uint8_t *s = coins;
  uint8_t *seed_se = coins + 16U;
  uint8_t *z = coins + 32U;
  uint8_t *seed_a = pk;
  Hacl_Hash_SHA3_shake128(seed_a, 16U, z, 16U);
  uint8_t *b_bytes = pk + 16U;
  uint8_t *s_bytes = sk + 992U;
  uint16_t s_matrix[512U] = { 0U };
  uint16_t e_matrix[512U] = { 0U };
  uint8_t r[2048U] = { 0U };
  uint8_t shake_input_seed_se[17U] = { 0U };
  shake_input_seed_se[0U] = 0x5fU;
  memcpy(shake_input_seed_se + 1U, seed_se, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(r, 2048U, shake_input_seed_se, 17U);
  Lib_Memzero0_memzero(shake_input_seed_se, 17U, uint8_t, void *);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(64U, 8U, r, s_matrix);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(64U, 8U, r + 1024U, e_matrix);
  uint16_t b_matrix[512U] = { 0U };
  uint16_t a_matrix[4096U] = { 0U };
  Hacl_Impl_Frodo_Params_frodo_gen_matrix(Spec_Frodo_Params_SHAKE128, 64U, seed_a, a_matrix);
  Hacl_Impl_Matrix_matrix_mul_s(64U, 64U, 8U, a_matrix, s_matrix, b_matrix);
  Hacl_Impl_Matrix_matrix_add(64U, 8U, b_matrix, e_matrix);
  Hacl_Impl_Frodo_Pack_frodo_pack(64U, 8U, 15U, b_matrix, b_bytes);
  Hacl_Impl_Matrix_matrix_to_lbytes(64U, 8U, s_matrix, s_bytes);
  Lib_Memzero0_memzero(s_matrix, 512U, uint16_t, void *);
  Lib_Memzero0_memzero(e_matrix, 512U, uint16_t, void *);
  uint32_t slen1 = 2016U;
  uint8_t *sk_p = sk;
  memcpy(sk_p, s, 16U * sizeof (uint8_t));
  memcpy(sk_p + 16U, pk, 976U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(sk + slen1, 16U, pk, 976U);
  Lib_Memzero0_memzero(coins, 48U, uint8_t, void *);
  return 0U;
}

uint32_t Hacl_Frodo64_crypto_kem_enc(uint8_t *ct, uint8_t *ss, uint8_t *pk)
{
  uint8_t coins[16U] = { 0U };
  randombytes_(16U, coins);
  uint8_t seed_se_k[32U] = { 0U };
  uint8_t pkh_mu[32U] = { 0U };
  Hacl_Hash_SHA3_shake128(pkh_mu, 16U, pk, 976U);
  memcpy(pkh_mu + 16U, coins, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(seed_se_k, 32U, pkh_mu, 32U);
  uint8_t *seed_se = seed_se_k;
  uint8_t *k = seed_se_k + 16U;
  uint8_t *seed_a = pk;
  uint8_t *b = pk + 16U;
  uint16_t sp_matrix[512U] = { 0U };
  uint16_t ep_matrix[512U] = { 0U };
  uint16_t epp_matrix[64U] = { 0U };
  uint8_t r[2176U] = { 0U };
  uint8_t shake_input_seed_se[17U] = { 0U };
  shake_input_seed_se[0U] = 0x96U;
  memcpy(shake_input_seed_se + 1U, seed_se, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(r, 2176U, shake_input_seed_se, 17U);
  Lib_Memzero0_memzero(shake_input_seed_se, 17U, uint8_t, void *);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(8U, 64U, r, sp_matrix);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(8U, 64U, r + 1024U, ep_matrix);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(8U, 8U, r + 2048U, epp_matrix);
  uint8_t *c1 = ct;
  uint8_t *c2 = ct + 960U;
  uint16_t bp_matrix[512U] = { 0U };
  uint16_t a_matrix[4096U] = { 0U };
  Hacl_Impl_Frodo_Params_frodo_gen_matrix(Spec_Frodo_Params_SHAKE128, 64U, seed_a, a_matrix);
  Hacl_Impl_Matrix_matrix_mul(8U, 64U, 64U, sp_matrix, a_matrix, bp_matrix);
  Hacl_Impl_Matrix_matrix_add(8U, 64U, bp_matrix, ep_matrix);
  Hacl_Impl_Frodo_Pack_frodo_pack(8U, 64U, 15U, bp_matrix, c1);
  uint16_t v_matrix[64U] = { 0U };
  uint16_t b_matrix[512U] = { 0U };
  Hacl_Impl_Frodo_Pack_frodo_unpack(64U, 8U, 15U, b, b_matrix);
  Hacl_Impl_Matrix_matrix_mul(8U, 64U, 8U, sp_matrix, b_matrix, v_matrix);
  Hacl_Impl_Matrix_matrix_add(8U, 8U, v_matrix, epp_matrix);
  uint16_t mu_encode[64U] = { 0U };
  Hacl_Impl_Frodo_Encode_frodo_key_encode(15U, 2U, 8U, coins, mu_encode);
  Hacl_Impl_Matrix_matrix_add(8U, 8U, v_matrix, mu_encode);
  Lib_Memzero0_memzero(mu_encode, 64U, uint16_t, void *);
  Hacl_Impl_Frodo_Pack_frodo_pack(8U, 8U, 15U, v_matrix, c2);
  Lib_Memzero0_memzero(v_matrix, 64U, uint16_t, void *);
  Lib_Memzero0_memzero(sp_matrix, 512U, uint16_t, void *);
  Lib_Memzero0_memzero(ep_matrix, 512U, uint16_t, void *);
  Lib_Memzero0_memzero(epp_matrix, 64U, uint16_t, void *);
  uint32_t ss_init_len = 1096U;
  KRML_CHECK_SIZE(sizeof (uint8_t), ss_init_len);
  uint8_t *shake_input_ss = (uint8_t *)alloca(ss_init_len * sizeof (uint8_t));
  memset(shake_input_ss, 0U, ss_init_len * sizeof (uint8_t));
  memcpy(shake_input_ss, ct, 1080U * sizeof (uint8_t));
  memcpy(shake_input_ss + 1080U, k, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(ss, 16U, shake_input_ss, ss_init_len);
  Lib_Memzero0_memzero(shake_input_ss, ss_init_len, uint8_t, void *);
  Lib_Memzero0_memzero(seed_se_k, 32U, uint8_t, void *);
  Lib_Memzero0_memzero(coins, 16U, uint8_t, void *);
  return 0U;
}

uint32_t Hacl_Frodo64_crypto_kem_dec(uint8_t *ss, uint8_t *ct, uint8_t *sk)
{
  uint16_t bp_matrix[512U] = { 0U };
  uint16_t c_matrix[64U] = { 0U };
  uint8_t *c1 = ct;
  uint8_t *c2 = ct + 960U;
  Hacl_Impl_Frodo_Pack_frodo_unpack(8U, 64U, 15U, c1, bp_matrix);
  Hacl_Impl_Frodo_Pack_frodo_unpack(8U, 8U, 15U, c2, c_matrix);
  uint8_t mu_decode[16U] = { 0U };
  uint8_t *s_bytes = sk + 992U;
  uint16_t s_matrix[512U] = { 0U };
  uint16_t m_matrix[64U] = { 0U };
  Hacl_Impl_Matrix_matrix_from_lbytes(64U, 8U, s_bytes, s_matrix);
  Hacl_Impl_Matrix_matrix_mul_s(8U, 64U, 8U, bp_matrix, s_matrix, m_matrix);
  Hacl_Impl_Matrix_matrix_sub(8U, 8U, c_matrix, m_matrix);
  Hacl_Impl_Frodo_Encode_frodo_key_decode(15U, 2U, 8U, m_matrix, mu_decode);
  Lib_Memzero0_memzero(s_matrix, 512U, uint16_t, void *);
  Lib_Memzero0_memzero(m_matrix, 64U, uint16_t, void *);
  uint8_t seed_se_k[32U] = { 0U };
  uint32_t pkh_mu_decode_len = 32U;
  KRML_CHECK_SIZE(sizeof (uint8_t), pkh_mu_decode_len);
  uint8_t *pkh_mu_decode = (uint8_t *)alloca(pkh_mu_decode_len * sizeof (uint8_t));
  memset(pkh_mu_decode, 0U, pkh_mu_decode_len * sizeof (uint8_t));
  uint8_t *pkh = sk + 2016U;
  memcpy(pkh_mu_decode, pkh, 16U * sizeof (uint8_t));
  memcpy(pkh_mu_decode + 16U, mu_decode, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(seed_se_k, 32U, pkh_mu_decode, pkh_mu_decode_len);
  uint8_t *seed_se = seed_se_k;
  uint8_t *kp = seed_se_k + 16U;
  uint8_t *s = sk;
  uint16_t bpp_matrix[512U] = { 0U };
  uint16_t cp_matrix[64U] = { 0U };
  uint16_t sp_matrix[512U] = { 0U };
  uint16_t ep_matrix[512U] = { 0U };
  uint16_t epp_matrix[64U] = { 0U };
  uint8_t r[2176U] = { 0U };
  uint8_t shake_input_seed_se[17U] = { 0U };
  shake_input_seed_se[0U] = 0x96U;
  memcpy(shake_input_seed_se + 1U, seed_se, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(r, 2176U, shake_input_seed_se, 17U);
  Lib_Memzero0_memzero(shake_input_seed_se, 17U, uint8_t, void *);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(8U, 64U, r, sp_matrix);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(8U, 64U, r + 1024U, ep_matrix);
  Hacl_Impl_Frodo_Sample_frodo_sample_matrix64(8U, 8U, r + 2048U, epp_matrix);
  uint8_t *pk = sk + 16U;
  uint8_t *seed_a = pk;
  uint8_t *b = pk + 16U;
  uint16_t a_matrix[4096U] = { 0U };
  Hacl_Impl_Frodo_Params_frodo_gen_matrix(Spec_Frodo_Params_SHAKE128, 64U, seed_a, a_matrix);
  Hacl_Impl_Matrix_matrix_mul(8U, 64U, 64U, sp_matrix, a_matrix, bpp_matrix);
  Hacl_Impl_Matrix_matrix_add(8U, 64U, bpp_matrix, ep_matrix);
  uint16_t b_matrix[512U] = { 0U };
  Hacl_Impl_Frodo_Pack_frodo_unpack(64U, 8U, 15U, b, b_matrix);
  Hacl_Impl_Matrix_matrix_mul(8U, 64U, 8U, sp_matrix, b_matrix, cp_matrix);
  Hacl_Impl_Matrix_matrix_add(8U, 8U, cp_matrix, epp_matrix);
  uint16_t mu_encode[64U] = { 0U };
  Hacl_Impl_Frodo_Encode_frodo_key_encode(15U, 2U, 8U, mu_decode, mu_encode);
  Hacl_Impl_Matrix_matrix_add(8U, 8U, cp_matrix, mu_encode);
  Lib_Memzero0_memzero(mu_encode, 64U, uint16_t, void *);
  Hacl_Impl_Matrix_mod_pow2(8U, 64U, 15U, bpp_matrix);
  Hacl_Impl_Matrix_mod_pow2(8U, 8U, 15U, cp_matrix);
  Lib_Memzero0_memzero(sp_matrix, 512U, uint16_t, void *);
  Lib_Memzero0_memzero(ep_matrix, 512U, uint16_t, void *);
  Lib_Memzero0_memzero(epp_matrix, 64U, uint16_t, void *);
  uint16_t b1 = Hacl_Impl_Matrix_matrix_eq(8U, 64U, bp_matrix, bpp_matrix);
  uint16_t b2 = Hacl_Impl_Matrix_matrix_eq(8U, 8U, c_matrix, cp_matrix);
  uint16_t mask = (uint32_t)b1 & (uint32_t)b2;
  uint16_t mask0 = mask;
  uint8_t kp_s[16U] = { 0U };
  KRML_MAYBE_FOR16(i,
    0U,
    16U,
    1U,
    uint8_t *os = kp_s;
    uint8_t uu____0 = s[i];
    uint8_t
    x = (uint32_t)uu____0 ^ ((uint32_t)(uint8_t)mask0 & ((uint32_t)kp[i] ^ (uint32_t)uu____0));
    os[i] = x;);
  uint32_t ss_init_len = 1096U;
  KRML_CHECK_SIZE(sizeof (uint8_t), ss_init_len);
  uint8_t *ss_init = (uint8_t *)alloca(ss_init_len * sizeof (uint8_t));
  memset(ss_init, 0U, ss_init_len * sizeof (uint8_t));
  memcpy(ss_init, ct, 1080U * sizeof (uint8_t));
  memcpy(ss_init + 1080U, kp_s, 16U * sizeof (uint8_t));
  Hacl_Hash_SHA3_shake128(ss, 16U, ss_init, ss_init_len);
  Lib_Memzero0_memzero(ss_init, ss_init_len, uint8_t, void *);
  Lib_Memzero0_memzero(kp_s, 16U, uint8_t, void *);
  Lib_Memzero0_memzero(seed_se_k, 32U, uint8_t, void *);
  Lib_Memzero0_memzero(mu_decode, 16U, uint8_t, void *);
  return 0U;
}

