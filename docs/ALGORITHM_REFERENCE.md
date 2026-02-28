# Libreswan Algorithm Support

Complete reference of all cryptographic algorithms supported by Libreswan, with the exact identifiers to use in `ike=` and `esp=` configuration parameters.

**Config syntax:**

| Scenario       | Syntax                             |
| -------------- | ---------------------------------- |
| IKE (non-AEAD) | `ike=encryption-integrity-dhgroup` |
| IKE (AEAD)     | `ike=encryption-prf-dhgroup`       |
| ESP (non-AEAD) | `esp=encryption-integrity`         |
| ESP (AEAD)     | `esp=encryption`                   |

> [!IMPORTANT]
> **IKE always needs a PRF.** Even with AEAD ciphers (which have built-in integrity), the `ike=` line requires a PRF algorithm for key derivation. The middle component in `ike=` is the **PRF** when using AEAD, not an integrity algorithm. For ESP, AEAD handles everything — no integrity or PRF is needed.

## IKE & ESP Encryption Algorithms

Used in both `ike=` and `esp=` parameters.

| Config Name(s)                          | Algorithm             | Key Sizes (bits) | Default Key | Mode | FIPS |
| --------------------------------------- | --------------------- | ---------------- | ----------- | ---- | ---- |
| `aes`, `aes_cbc`                        | AES-CBC               | 128, 192, 256    | 256         | CBC  | Yes  |
| `aesctr`, `aes_ctr`                     | AES-CTR               | 128, 192, 256    | 256         | CTR  | Yes  |
| `aes_gcm`, `aes_gcm_16`, `aes_gcm_c`    | AES-GCM (16-byte ICV) | 128, 192, 256    | 256         | AEAD | Yes  |
| `aes_gcm_12`, `aes_gcm_b`               | AES-GCM (12-byte ICV) | 128, 192, 256    | 256         | AEAD | Yes  |
| `aes_gcm_8`, `aes_gcm_a`                | AES-GCM (8-byte ICV)  | 128, 192, 256    | 256         | AEAD | Yes  |
| `aes_ccm`, `aes_ccm_16`, `aes_ccm_c`    | AES-CCM (16-byte ICV) | 128, 192, 256    | 256         | AEAD | Yes  |
| `aes_ccm_12`, `aes_ccm_b`               | AES-CCM (12-byte ICV) | 128, 192, 256    | 256         | AEAD | Yes  |
| `aes_ccm_8`, `aes_ccm_a`                | AES-CCM (8-byte ICV)  | 128, 192, 256    | 256         | AEAD | Yes  |
| `null_auth_aes_gmac`, `aes_gmac`        | NULL-Auth AES-GMAC    | 128, 192, 256    | 256         | AEAD | Yes  |
| `3des`, `3des_cbc`                      | 3DES-CBC              | 192 (fixed)      | 192         | CBC  | Yes  |
| `camellia`, `camellia_cbc`              | Camellia-CBC          | 128, 192, 256    | 256         | CBC  | No   |
| `camellia_ctr`                          | Camellia-CTR          | 128, 192, 256    | 256         | CTR  | No   |
| `chacha20_poly1305`, `chacha20poly1305` | ChaCha20-Poly1305     | 256 (fixed)      | 256         | AEAD | No   |
| `null`                                  | NULL (no encryption)  | —                | —           | —    | No   |

> [!IMPORTANT]
> **Key size selection:** The key size is appended to the **config name** (not the mode). Three formats are supported:
>
> | Format                                                                                   | Example        | Meaning                     |
> | ---------------------------------------------------------------------------------------- | -------------- | --------------------------- |
> | `<name><size>` (exception: not applicable to names ending with numbers like `aes_gcm_8`) | `aes_gcm_a128` | AES-GCM-8 with 128-bit key  |
> | `<name>_<size>`                                                                          | `aes_gcm_256`  | AES-GCM-16 with 256-bit key |
> | `<name>-<size>`                                                                          | `aes_ctr-128`  | AES-CTR with 128-bit key    |
>
> When no key size is specified, the **Default Key** from the table above is used.

> [!NOTE]
> **AEAD ciphers:** When using AEAD encryption (GCM, CCM, ChaCha20-Poly1305), do **not** specify a separate integrity algorithm — integrity is built in.

## IKE & ESP Integrity (Authentication) Algorithms

Used in both `ike=` and `esp=` for non-AEAD ciphers. Not used with AEAD ciphers.

| Config Name(s)                                                                     | Algorithm                      | Truncation | FIPS |
| ---------------------------------------------------------------------------------- | ------------------------------ | ---------- | ---- |
| `sha2_256`, `sha256`, `sha2`, `sha2_256_128`, `hmac_sha2_256`, `hmac_sha2_256_128` | HMAC-SHA2-256                  | 128 bits   | Yes  |
| `sha2_384`, `sha384`, `sha2_384_192`, `hmac_sha2_384`, `hmac_sha2_384_192`         | HMAC-SHA2-384                  | 192 bits   | Yes  |
| `sha2_512`, `sha512`, `sha2_512_256`, `hmac_sha2_512`, `hmac_sha2_512_256`         | HMAC-SHA2-512                  | 256 bits   | Yes  |
| `hmac_sha2_256_truncbug`                                                           | HMAC-SHA2-256 (truncation bug) | 96 bits    | No   |
| `sha1`, `sha`, `sha1_96`, `hmac_sha1`, `hmac_sha1_96`                              | HMAC-SHA1                      | 96 bits    | Yes  |
| `md5`, `hmac_md5`, `hmac_md5_96`                                                   | HMAC-MD5                       | 96 bits    | No   |
| `aes_xcbc`, `aes128_xcbc`, `aes_xcbc_96`, `aes128_xcbc_96`                         | AES-XCBC                       | 96 bits    | No   |
| `aes_cmac`, `aes_cmac_96`                                                          | AES-CMAC                       | 96 bits    | Yes  |
| `none`, `null`                                                                     | No integrity                   | —          | Yes  |

> [!NOTE]
> **`hmac_sha2_256_truncbug`:** IKEv1-only compat entry for interoperating with broken implementations that truncate SHA2-256 to 96 bits instead of 128 bits. Not usable for IKEv2.

> [!NOTE]
> **`none` integrity FIPS:** Marked FIPS-approved because AEAD ciphers (e.g., AES-GCM) implicitly require `none` as the integrity selection. Other code rejects `none` integrity for non-AEAD ciphers.

## IKE PRF (Pseudo-Random Function) Algorithms

Used only in `ike=` parameter (the PRF is always negotiated for IKE, but in practice shares the name with the integrity algorithm and is auto-selected).

| Config Name(s)                                | Algorithm     | Output Size | FIPS |
| --------------------------------------------- | ------------- | ----------- | ---- |
| `sha2_256`, `sha256`, `sha2`, `hmac_sha2_256` | HMAC-SHA2-256 | 256 bits    | Yes  |
| `sha2_384`, `sha384`, `hmac_sha2_384`         | HMAC-SHA2-384 | 384 bits    | Yes  |
| `sha2_512`, `sha512`, `hmac_sha2_512`         | HMAC-SHA2-512 | 512 bits    | Yes  |
| `sha1`, `sha`, `hmac_sha1`                    | HMAC-SHA1     | 160 bits    | Yes  |
| `md5`, `hmac_md5`                             | HMAC-MD5      | 128 bits    | No   |
| `aes128_xcbc`, `aes_xcbc`                     | AES-XCBC      | 128 bits    | No   |

## Hash Algorithms

Internally used for digital signatures (IKEv2 AUTH). These are not directly user-configurable via `ike=`/`esp=`, but are part of the algorithm infrastructure.

| Config Name(s)               | Algorithm | Digest Size | FIPS |
| ---------------------------- | --------- | ----------- | ---- |
| `sha2`, `sha256`, `sha2_256` | SHA2-256  | 256 bits    | Yes  |
| `sha384`, `sha2_384`         | SHA2-384  | 384 bits    | Yes  |
| `sha512`, `sha2_512`         | SHA2-512  | 512 bits    | Yes  |
| `sha`, `sha1`                | SHA1      | 160 bits    | Yes  |
| `md5`                        | MD5       | 128 bits    | No   |
| `identity`                   | Identity  | —           | Yes  |

## DH / KEM Groups (Key Exchange)

Used in `ike=` as the third component (e.g., `ike=aes256-sha2_256-modp2048`).

### MODP (Finite Field) Groups

| Config Name(s)     | Group         | Size (bits) | Build Flag | FIPS |
| ------------------ | ------------- | ----------- | ---------- | ---- |
| `modp1024`, `dh2`  | MODP Group 2  | 1024        | `USE_DH2`  | No   |
| `modp1536`, `dh5`  | MODP Group 5  | 1536        | —          | No   |
| `modp2048`, `dh14` | MODP Group 14 | 2048        | —          | Yes  |
| `modp3072`, `dh15` | MODP Group 15 | 3072        | —          | Yes  |
| `modp4096`, `dh16` | MODP Group 16 | 4096        | —          | Yes  |
| `modp6144`, `dh17` | MODP Group 17 | 6144        | —          | Yes  |
| `modp8192`, `dh18` | MODP Group 18 | 8192        | —          | Yes  |

### Elliptic Curve Groups

| Config Name(s)              | Curve                  | Size (bits) | Build Flag | FIPS |
| --------------------------- | ---------------------- | ----------- | ---------- | ---- |
| `dh19`, `ecp_256`, `ecp256` | NIST P-256 (secp256r1) | 256         | —          | Yes  |
| `dh20`, `ecp_384`, `ecp384` | NIST P-384 (secp384r1) | 384         | —          | Yes  |
| `dh21`, `ecp_521`, `ecp521` | NIST P-521 (secp521r1) | 521         | —          | Yes  |
| `dh31`, `curve25519`        | Curve25519             | 255         | `USE_DH31` | No   |
| `dh32`, `curve448`          | Curve448               | 448         | `USE_DH32` | No   |

### Uncommon / Legacy DH Groups

| Config Name(s) | Group                               | Size (bits) | Build Flag | FIPS |
| -------------- | ----------------------------------- | ----------- | ---------- | ---- |
| `dh22`         | 1024-bit MODP with 160-bit subgroup | 1024        | `USE_DH22` | No   |
| `dh23`         | 2048-bit MODP with 224-bit subgroup | 2048        | `USE_DH23` | No   |
| `dh24`         | 2048-bit MODP with 256-bit subgroup | 2048        | `USE_DH24` | No   |

### Post-Quantum KEM (IKEv2 only)

ML-KEM algorithms **cannot be used alone** — they must be combined with a classical DH group using the `+` syntax to form a **hybrid key exchange**.

| Config Name(s)             | Algorithm                      | Build Flag        | FIPS |
| -------------------------- | ------------------------------ | ----------------- | ---- |
| `ml_kem_512`, `mlkem512`   | ML-KEM-512 (128-bit security)  | `USE_ML_KEM_512`  | No   |
| `ml_kem_768`, `mlkem768`   | ML-KEM-768 (192-bit security)  | `USE_ML_KEM_768`  | No   |
| `ml_kem_1024`, `mlkem1024` | ML-KEM-1024 (256-bit security) | `USE_ML_KEM_1024` | No   |

> [!IMPORTANT]
> **Hybrid key exchange syntax:** `<classical DH>+<ML-KEM>` — the classical group comes **first**, then `+`, then the post-quantum KEM.
>
> | Valid hybrid combinations | Meaning                 |
> | ------------------------- | ----------------------- |
> | `ecp384+mlkem768`         | P-384 + ML-KEM-768      |
> | `curve25519+mlkem768`     | Curve25519 + ML-KEM-768 |
> | `modp2048+mlkem512`       | MODP-2048 + ML-KEM-512  |
> | `ecp521+mlkem1024`        | P-521 + ML-KEM-1024     |
>
> Any classical group (MODP, ECP, Curve25519) can be paired with any ML-KEM variant.

### Special

| Config Name(s)        | Description                     |
| --------------------- | ------------------------------- |
| `none`, `null`, `dh0` | No DH / PFS disabled (ESP only) |

## IPComp Algorithms

Used with `compress=yes` in connection config.

| Config Name | Algorithm          |
| ----------- | ------------------ |
| `deflate`   | DEFLATE (RFC 2394) |
| `lzs`       | LZS (RFC 2395)     |
| `lzjh`      | LZJH (RFC 3051)    |

## Extended Sequence Numbers (ESN)

Used internally for IKEv2 ESP/AH negotiation. Configured via `esn=` in connection config.

| Config Name(s)                     | Description                                |
| ---------------------------------- | ------------------------------------------ |
| `32_bit_sequential`, `no`          | 32-bit sequence numbers (standard, no ESN) |
| `partial_64_bit_sequential`, `yes` | 64-bit extended sequence numbers (ESN)     |

> [!NOTE]
> The `esn=yes` or `esn=no` shorthand is the typical way to configure ESN in `ipsec.conf`.

## Configuration Examples

**Strong IKEv2 with AES-GCM (AEAD):**

```
ike=aes_gcm256-sha2_512-ecp384
esp=aes_gcm256
```

**Classic AES-CBC + SHA2:**

```
ike=aes256-sha2_256-modp2048
esp=aes256-sha2_256
```

**Post-quantum hybrid (IKEv2 only):**

```
ike=aes256-sha2_512-ecp384+mlkem768
```

**ChaCha20-Poly1305 (AEAD):**

```
ike=chacha20_poly1305-sha2_512-curve25519
esp=chacha20_poly1305
```

**Multiple proposals (comma-separated):**

```
ike=aes_gcm256-sha2_512-ecp384,aes256-sha2_256-modp2048
esp=aes_gcm256,aes256-sha2_256
```
