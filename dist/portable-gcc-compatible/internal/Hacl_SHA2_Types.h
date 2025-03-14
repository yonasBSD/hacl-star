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


#ifndef __internal_Hacl_SHA2_Types_H
#define __internal_Hacl_SHA2_Types_H

#if defined(__cplusplus)
extern "C" {
#endif

#include "../Hacl_SHA2_Types.h"

/* SNIPPET_START: Hacl_Hash_SHA2_uint8_5p */

typedef struct Hacl_Hash_SHA2_uint8_5p_s
{
  uint8_t *fst;
  Hacl_Hash_SHA2_uint8_4p snd;
}
Hacl_Hash_SHA2_uint8_5p;

/* SNIPPET_END: Hacl_Hash_SHA2_uint8_5p */

/* SNIPPET_START: Hacl_Hash_SHA2_uint8_6p */

typedef struct Hacl_Hash_SHA2_uint8_6p_s
{
  uint8_t *fst;
  Hacl_Hash_SHA2_uint8_5p snd;
}
Hacl_Hash_SHA2_uint8_6p;

/* SNIPPET_END: Hacl_Hash_SHA2_uint8_6p */

/* SNIPPET_START: Hacl_Hash_SHA2_uint8_7p */

typedef struct Hacl_Hash_SHA2_uint8_7p_s
{
  uint8_t *fst;
  Hacl_Hash_SHA2_uint8_6p snd;
}
Hacl_Hash_SHA2_uint8_7p;

/* SNIPPET_END: Hacl_Hash_SHA2_uint8_7p */

/* SNIPPET_START: Hacl_Hash_SHA2_uint8_8p */

typedef struct Hacl_Hash_SHA2_uint8_8p_s
{
  uint8_t *fst;
  Hacl_Hash_SHA2_uint8_7p snd;
}
Hacl_Hash_SHA2_uint8_8p;

/* SNIPPET_END: Hacl_Hash_SHA2_uint8_8p */

/* SNIPPET_START: Hacl_Hash_SHA2_uint8_2x4p */

typedef struct Hacl_Hash_SHA2_uint8_2x4p_s
{
  Hacl_Hash_SHA2_uint8_4p fst;
  Hacl_Hash_SHA2_uint8_4p snd;
}
Hacl_Hash_SHA2_uint8_2x4p;

/* SNIPPET_END: Hacl_Hash_SHA2_uint8_2x4p */

/* SNIPPET_START: Hacl_Hash_SHA2_uint8_2x8p */

typedef struct Hacl_Hash_SHA2_uint8_2x8p_s
{
  Hacl_Hash_SHA2_uint8_8p fst;
  Hacl_Hash_SHA2_uint8_8p snd;
}
Hacl_Hash_SHA2_uint8_2x8p;

/* SNIPPET_END: Hacl_Hash_SHA2_uint8_2x8p */

#if defined(__cplusplus)
}
#endif

#define __internal_Hacl_SHA2_Types_H_DEFINED
#endif
