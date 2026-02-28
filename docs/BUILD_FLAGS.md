# Libreswan Build Flags

All flags are set via `Makefile.inc.local` in the Libreswan source root, or passed as `make` arguments (e.g., `make USE_SECCOMP=true base`).

## Feature Flags

| Flag                   | Default                  | Description                                                           |
| ---------------------- | ------------------------ | --------------------------------------------------------------------- |
| `USE_IKEv1`            | `true`                   | IKEv1 protocol support                                                |
| `USE_DNSSEC`           | `true`                   | DNSSEC validation (needs libunbound + libldns)                        |
| `USE_UNBOUND`          | `= USE_DNSSEC`           | Link against libunbound                                               |
| `USE_LDNS`             | `= USE_DNSSEC`           | Link against libldns                                                  |
| `USE_LIBCURL`          | `true`                   | CRL fetching via libcurl                                              |
| `USE_AUTHPAM`          | `true` (not OpenBSD)     | PAM authentication                                                    |
| `USE_LIBCAP_NG`        | `true` (not BSDs)        | Privilege dropping                                                    |
| `USE_SYSTEMD_WATCHDOG` | `true` if systemd        | systemd notify + watchdog heartbeat                                   |
| `USE_NSS_KDF`          | `true`                   | FIPS-compliant KDF (needs NSS ≥ 3.52)                                 |
| `USE_EDDSA`            | `true`                   | EdDSA signature support (needs NSS ≥ 3.99)                            |
| `USE_FORK`             | `true`                   | Fork for daemonization                                                |
| `USE_VFORK`            | `false`                  | Use vfork instead (for no-MMU systems)                                |
| `USE_DAEMON`           | `false`                  | Use daemon() for detaching                                            |
| `USE_SECCOMP`          | `false` (auto on Fedora) | seccomp syscall whitelist                                             |
| `USE_LABELED_IPSEC`    | `false` (auto on Fedora) | SELinux labeled IPsec                                                 |
| `USE_LINUX_AUDIT`      | `false` (auto on Fedora) | Audit logging                                                         |
| `USE_LDAP`             | `false`                  | LDAP support                                                          |
| `USE_EFENCE`           | `false`                  | ElectricFence memory debugger                                         |
| `ENABLE_IPSECKEY`      | auto                     | IPSECKEY support (auto `true` when both UNBOUND and LDNS are enabled) |

## Kernel / Network Flags

| Flag                   | Default                     | Description                                           |
| ---------------------- | --------------------------- | ----------------------------------------------------- |
| `USE_XFRM`             | `true` on Linux             | Linux XFRM/NETKEY interface                           |
| `USE_PFKEYV2`          | `true` on BSDs              | KAME-derived pfkey interface                          |
| `USE_XFRM_INTERFACE`   | `= USE_XFRM`                | XFRM interface devices (kernel ≥ 4.19)                |
| `USE_XFRM_HEADER_COPY` | auto on older Debian/Ubuntu | Use bundled xfrm.h when system headers are outdated   |
| `USE_NFTABLES`         | `true` on Linux             | nftables firewall backend                             |
| `USE_IPTABLES`         | `false`                     | iptables backend (mutually exclusive with nftables)   |
| `USE_CAT`              | `true` on Linux             | Client Address Translation (needs a firewall backend) |
| `USE_NFLOG`            | `true` on Linux             | NFLOG support (needs a firewall backend)              |

## Crypto Algorithm Flags

| Flag               | Default                           | Notes                               |
| ------------------ | --------------------------------- | ----------------------------------- |
| `USE_AES`          | `true`                            | AES encryption                      |
| `USE_3DES`         | `true`                            | 3DES encryption                     |
| `USE_CAMELLIA`     | `true`                            | Camellia encryption                 |
| `USE_CHACHA`       | `true` (`false` on NetBSD)        | ChaCha20-Poly1305                   |
| `USE_DH2`          | `false`                           | MODP-1024 (weak, for interop only)  |
| `USE_DH22`         | `false`                           | 1024-bit MODP with 160-bit subgroup |
| `USE_DH23`         | `false`                           | 2048-bit MODP with 224-bit subgroup |
| `USE_DH24`         | `false`                           | 2048-bit MODP with 256-bit subgroup |
| `USE_DH31`         | `true`                            | Curve25519 DH                       |
| `USE_MD5`          | `true`                            | MD5 PRF                             |
| `USE_SHA1`         | `true`                            | SHA-1 PRF                           |
| `USE_SHA2`         | `true`                            | SHA-256/384/512                     |
| `USE_ML_KEM_512`   | `false`                           | Post-quantum ML-KEM 128-bit         |
| `USE_ML_KEM_768`   | `true` (disabled on older Ubuntu) | Post-quantum ML-KEM 192-bit         |
| `USE_ML_KEM_1024`  | `false`                           | Post-quantum ML-KEM 256-bit         |
| `USE_PRF_AES_XCBC` | `true`                            | AES-XCBC PRF                        |
| `ALL_ALGS`         | `false`                           | Master switch — enable everything   |

## Installation Paths

| Variable         | Default                       | BSD Default                      | Description                                |
| ---------------- | ----------------------------- | -------------------------------- | ------------------------------------------ |
| `PREFIX`         | `/usr/local`                  | `/usr/local`                     | Base install prefix                        |
| `DESTDIR`        | _(empty)_                     | _(empty)_                        | Staging prefix for packaging               |
| `LIBEXECDIR`     | `$(PREFIX)/libexec/ipsec`     | `$(PREFIX)/libexec/ipsec`        | Helper programs (whack, \_pluto_adns, etc) |
| `SBINDIR`        | `$(PREFIX)/sbin`              | `$(PREFIX)/sbin`                 | Main `ipsec` command location              |
| `SYSCONFDIR`     | `/etc`                        | `$(PREFIX)/etc`                  | Config directory                           |
| `IPSEC_CONF`     | `$(SYSCONFDIR)/ipsec.conf`    | same                             | Main config file path                      |
| `IPSEC_SECRETS`  | `$(SYSCONFDIR)/ipsec.secrets` | same                             | Secrets file path                          |
| `IPSEC_CONFDDIR` | `$(SYSCONFDIR)/ipsec.d`       | same                             | Drop-in config directory                   |
| `NSSDIR`         | `/var/lib/ipsec/nss`          | `$(PREFIX)/etc/ipsec.d`          | NSS certificate database                   |
| `RUNDIR`         | `/run/pluto`                  | `/var/run/pluto`                 | PID file and control socket                |
| `LOGDIR`         | `/var/log`                    | `/var/log`                       | Log directory                              |
| `LOGFILE`        | `$(LOGDIR)/pluto.log`         | `$(LOGDIR)/pluto.log`            | Pluto log file                             |
| `MANDIR`         | `$(PREFIX)/share/man`         | `$(PREFIX)/man` (OpenBSD/NetBSD) | Man pages                                  |

## Compiler & Hardening Flags

| Variable          | Default                             | Purpose                                          |
| ----------------- | ----------------------------------- | ------------------------------------------------ |
| `DEBUG_CFLAGS`    | `-g`                                | Debug symbols                                    |
| `WERROR_CFLAGS`   | `-Werror`                           | Treat warnings as errors (set empty to relax)    |
| `OPTIMIZE_CFLAGS` | `-O2 -D_FORTIFY_SOURCE=2`           | Optimization                                     |
| `USERCOMPILE`     | `-fstack-protector-all -fPIE -DPIE` | Stack protection + PIE                           |
| `WARNING_CFLAGS`  | `-Wall -Wextra …`                   | Warning verbosity                                |
| `USERLINK`        | `-Wl,-z,relro,-z,now -pie`          | RELRO + PIE linking                              |
| `USE_LTO`         | `false` (broken on BSDs)            | Link-Time Optimization                           |
| `LTO_CFLAGS`      | `-flto`                             | Added to CFLAGS when USE_LTO=true                |
| `ASAN`            | _(empty)_                           | Set to `-fsanitize=address` for AddressSanitizer |

## Systemd Integration

Only applies on Linux with systemd.

| Variable             | Default              | Description                                        |
| -------------------- | -------------------- | -------------------------------------------------- |
| `INITSYSTEM`         | auto-detected        | `systemd`, `sysvinit`, `upstart`, `openrc`, `rc.d` |
| `SD_TYPE`            | `notify` or `simple` | Service type (notify if watchdog enabled)          |
| `SD_WATCHDOGSEC`     | `200`                | Seconds before systemd kills unresponsive pluto    |
| `SD_RESTART_TYPE`    | `on-failure`         | systemd Restart= policy                            |
| `SD_PLUTO_OPTIONS`   | `--leak-detective`   | Default pluto flags                                |
| `INSTALL_INITSYSTEM` | `true`               | Install init scripts during make install           |

## DNSSEC Root Key

Required when `USE_DNSSEC=true`. Auto-detected per OS:

| Variable                      | OS              | Default Path                             |
| ----------------------------- | --------------- | ---------------------------------------- |
| `DEFAULT_DNSSEC_ROOTKEY_FILE` | Debian / Ubuntu | `/usr/share/dns/root.key`                |
|                               | Fedora / RHEL   | `/var/lib/unbound/root.key`              |
|                               | Alpine          | `/usr/share/dnssec-root/trusted-key.key` |
|                               | Arch            | `/etc/trusted-key.key`                   |
|                               | FreeBSD         | `/usr/local/etc/unbound/root.key`        |
|                               | OpenBSD         | `/var/unbound/db/root.key`               |
|                               | NetBSD          | `/usr/pkg/etc/unbound/root.key`          |
|                               | Darwin          | DNSSEC disabled                          |
