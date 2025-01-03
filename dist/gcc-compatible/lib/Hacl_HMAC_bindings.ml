open Ctypes
module Bindings(F:Cstubs.FOREIGN) =
  struct
    open F
    let hacl_HMAC_compute_md5 =
      foreign "Hacl_HMAC_compute_md5"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha1 =
      foreign "Hacl_HMAC_compute_sha1"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha2_224 =
      foreign "Hacl_HMAC_compute_sha2_224"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha2_256 =
      foreign "Hacl_HMAC_compute_sha2_256"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha2_384 =
      foreign "Hacl_HMAC_compute_sha2_384"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha2_512 =
      foreign "Hacl_HMAC_compute_sha2_512"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha3_224 =
      foreign "Hacl_HMAC_compute_sha3_224"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha3_256 =
      foreign "Hacl_HMAC_compute_sha3_256"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha3_384 =
      foreign "Hacl_HMAC_compute_sha3_384"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_sha3_512 =
      foreign "Hacl_HMAC_compute_sha3_512"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_blake2s_32 =
      foreign "Hacl_HMAC_compute_blake2s_32"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
    let hacl_HMAC_compute_blake2b_32 =
      foreign "Hacl_HMAC_compute_blake2b_32"
        (ocaml_bytes @->
           (ocaml_bytes @->
              (uint32_t @-> (ocaml_bytes @-> (uint32_t @-> (returning void))))))
  end