# Libreswan ipsec.conf Configuration Parameters

Complete reference of all parameters that can be set in `ipsec.conf`.

## Config File Structure

```
config setup
    # global daemon parameters go here

conn <name>
    # per-connection parameters go here
```

## config setup Parameters

Global parameters that control the pluto IKE daemon behavior. Source: [`lib/libswan/ipsecconf/setup.c`](https://github.com/libreswan/libreswan/blob/main/lib/libswan/ipsecconf/setup.c)

### Daemon & Logging

| Parameter    | Type     | Default              | Description                                                                |
| ------------ | -------- | -------------------- | -------------------------------------------------------------------------- |
| `plutodebug` | string   | _(none)_             | Debug flags (comma-separated). Use `all` for everything, `none` to disable |
| `logfile`    | string   | `/var/log/pluto.log` | Log file path                                                              |
| `logtime`    | yes/no   | `yes`                | Include timestamps in log messages                                         |
| `logappend`  | yes/no   | `yes`                | Append to log file instead of overwriting                                  |
| `logip`      | yes/no   | `yes`                | Include IP addresses in log messages                                       |
| `audit-log`  | yes/no   | `yes`                | Enable audit logging                                                       |
| `dumpdir`    | string   | `$RUNDIR`            | Directory for core dumps                                                   |
| `statsbin`   | string   | _(none)_             | Script to call with connection statistics                                  |
| `nhelpers`   | unsigned | `-1` (auto)          | Number of crypto helper threads. `-1` = auto-detect                        |

### Directories & Files

| Parameter         | Type   | Default              | Description                                                                  |
| ----------------- | ------ | -------------------- | ---------------------------------------------------------------------------- |
| `ipsecdir`        | string | `/etc/ipsec.d`       | Drop-in config directory                                                     |
| `nssdir`          | string | `/var/lib/ipsec/nss` | NSS certificate database directory                                           |
| `secretsfile`     | string | `/etc/ipsec.secrets` | Secrets file path                                                            |
| `virtual-private` | string | _(none)_             | Virtual private networks for NAT-T (e.g., `%v4:10.0.0.0/8,%v4:!10.0.1.0/24`) |

### IKE Protocol

| Parameter             | Type     | Default       | Description                                                  |
| --------------------- | -------- | ------------- | ------------------------------------------------------------ |
| `uniqueids`           | yes/no   | `yes`         | Enforce unique IKE SA IDs (replace older SAs from same peer) |
| `ikev1-policy`        | sparse   | `drop`        | Global IKEv1 policy: `accept`, `reject`, or `drop`           |
| `protostack`          | string   | `xfrm`        | Kernel IPsec stack: `xfrm` (Linux) or `pfkeyv2` (BSDs)       |
| `listen`              | string   | _(all)_       | IP address(es) to listen on for IKE                          |
| `listen-udp`          | yes/no   | `yes`         | Listen on UDP ports 500/4500                                 |
| `listen-tcp`          | yes/no   | `no`          | Listen on TCP port 4500 (RFC 8229)                           |
| `ike-socket-bufsize`  | unsigned | _(system)_    | IKE socket buffer size                                       |
| `ike-socket-errqueue` | yes/no   | `yes`         | Enable socket error queue                                    |
| `keep-alive`          | seconds  | _(none)_      | NAT-T keep-alive interval                                    |
| `myvendorid`          | string   | _(libreswan)_ | Custom vendor ID string                                      |

### DDoS Protection

| Parameter            | Type     | Default          | Description                                       |
| -------------------- | -------- | ---------------- | ------------------------------------------------- |
| `ddos-mode`          | sparse   | `auto`           | DDoS protection mode: `auto`, `busy`, `unlimited` |
| `ddos-ike-threshold` | unsigned | _(compile-time)_ | IKE SA count threshold for DDoS mode              |
| `max-halfopen-ike`   | unsigned | _(compile-time)_ | Maximum number of half-open IKE SAs               |

### CRL & OCSP (Certificate Revocation)

| Parameter            | Type     | Default     | Description                            |
| -------------------- | -------- | ----------- | -------------------------------------- |
| `crl-strict`         | yes/no   | `no`        | Require valid CRL for certificate auth |
| `crlcheckinterval`   | seconds  | _(none)_    | CRL refresh interval                   |
| `crl-timeout`        | seconds  | `5s`        | CRL fetch timeout                      |
| `ocsp-enable`        | yes/no   | `no`        | Enable OCSP certificate checking       |
| `ocsp-strict`        | yes/no   | `no`        | Require valid OCSP response            |
| `ocsp-uri`           | string   | _(none)_    | Global OCSP responder URI              |
| `ocsp-trustname`     | string   | _(none)_    | OCSP trust anchor name                 |
| `ocsp-timeout`       | seconds  | _(default)_ | OCSP responder timeout                 |
| `ocsp-cache-size`    | unsigned | _(default)_ | OCSP response cache size               |
| `ocsp-cache-min-age` | seconds  | _(default)_ | Minimum OCSP cache age                 |
| `ocsp-cache-max-age` | seconds  | _(default)_ | Maximum OCSP cache age                 |
| `ocsp-method`        | sparse   | `get`       | OCSP method: `get`, `post`, `both`     |

### DNSSEC

| Parameter             | Type   | Default    | Description                   |
| --------------------- | ------ | ---------- | ----------------------------- |
| `dnssec-enable`       | yes/no | `yes`      | Enable DNSSEC validation      |
| `dnssec-rootkey-file` | string | _(per-OS)_ | DNSSEC root trust anchor file |
| `dnssec-anchors`      | string | _(none)_   | DNSSEC anchor file            |
| `dns-resolver`        | string | `file`     | DNS resolver mode             |

### Security & Misc

| Parameter                 | Type     | Default     | Description                                     |
| ------------------------- | -------- | ----------- | ----------------------------------------------- |
| `seccomp`                 | sparse   | `disabled`  | seccomp mode: `enabled`, `tolerant`, `disabled` |
| `global-redirect`         | sparse   | `no`        | Global IKEv2 redirect: `no`, `yes`, `auto`      |
| `global-redirect-to`      | string   | _(none)_    | Redirect destination IP                         |
| `seedbits`                | unsigned | _(default)_ | Number of seed bits for NSS RNG                 |
| `drop-oppo-null`          | yes/no   | `no`        | Drop opportunistic NULL auth connections        |
| `curl-iface`              | string   | _(none)_    | Outgoing interface for CRL/OCSP fetches         |
| `shuntlifetime`           | seconds  | _(default)_ | Bare shunt SA lifetime                          |
| `expire-shunt-interval`   | seconds  | _(default)_ | Interval for expiring shunts                    |
| `expire-lifetime`         | seconds  | _(none)_    | Override kernel SA lifetime expiry              |
| `nflog-all`               | unsigned | _(none)_    | Global NFLOG group number                       |
| `ipsec-interface-managed` | yes/no   | _(none)_    | Managed XFRM interface mode                     |

## conn Parameters

Per-connection parameters. Source: [`lib/libswan/ipsecconf/conn.c`](https://github.com/libreswan/libreswan/blob/main/lib/libswan/ipsecconf/conn.c)

### Endpoint Identity (left/right)

These parameters come in `left` and `right` variants. `left` is typically the local side.

| Parameter                                  | Type   | Description                                                      |
| ------------------------------------------ | ------ | ---------------------------------------------------------------- |
| `left` / `right`                           | string | IP address, `%defaultroute`, `%any`, FQDN, or `%group`           |
| `leftsubnet` / `rightsubnet`               | string | Protected subnet (e.g., `192.168.1.0/24`). Omit for host-to-host |
| `leftsubnets` / `rightsubnets`             | string | Multiple subnets (creates multiple SAs)                          |
| `leftsourceip` / `rightsourceip`           | string | Source IP for outgoing packets in tunnel                         |
| `leftnexthop` / `rightnexthop`             | string | Next hop gateway IP                                              |
| `leftid` / `rightid`                       | string | Identity for IKE negotiation (DN, FQDN, @name, IP)               |
| `leftupdown` / `rightupdown`               | string | Script to run on connection state changes                        |
| `leftupdown-config` / `rightupdown-config` | string | Config vars passed to updown script                              |

### Authentication Keys (left/right)

| Parameter                          | Type   | Description                                                          |
| ---------------------------------- | ------ | -------------------------------------------------------------------- |
| `leftrsasigkey` / `rightrsasigkey` | string | RSA public key or `%cert`, `%dnsondemand`, `%dns`                    |
| `leftecdsakey` / `rightecdsakey`   | string | ECDSA public key                                                     |
| `lefteddsakey` / `righteddsakey`   | string | EdDSA public key                                                     |
| `leftpubkey` / `rightpubkey`       | string | Generic public key                                                   |
| `leftcert` / `rightcert`           | string | X.509 certificate nickname in NSS database                           |
| `leftckaid` / `rightckaid`         | string | Certificate Key Attribute ID                                         |
| `leftca` / `rightca`               | string | CA distinguished name                                                |
| `leftsendcert` / `rightsendcert`   | string | When to send certificate: `always`, `sendifasked`, `never`           |
| `leftauth` / `rightauth`           | string | Per-side auth method: `rsasig`, `ecdsa`, `secret`, `eaponly`, `null` |
| `leftautheap` / `rightautheap`     | string | EAP authentication method                                            |

### XAUTH & ModeCfg (left/right)

| Parameter                                  | Type   | Description                                          |
| ------------------------------------------ | ------ | ---------------------------------------------------- |
| `leftxauthserver` / `rightxauthserver`     | string | XAUTH server role                                    |
| `leftxauthclient` / `rightxauthclient`     | string | XAUTH client role                                    |
| `leftmodecfgserver` / `rightmodecfgserver` | string | Mode Config server role                              |
| `leftmodecfgclient` / `rightmodecfgclient` | string | Mode Config client role                              |
| `leftusername` / `rightusername`           | string | XAUTH/EAP username                                   |
| `leftaddresspool` / `rightaddresspool`     | string | IP address pool range (e.g., `10.0.0.10-10.0.0.250`) |

### Network (left/right)

| Parameter                                | Type   | Description                                                      |
| ---------------------------------------- | ------ | ---------------------------------------------------------------- |
| `leftprotoport` / `rightprotoport`       | string | Protocol/port selector (e.g., `17/1701` for L2TP, `6/0` for TCP) |
| `leftikeport` / `rightikeport`           | string | Override IKE port (default: 500)                                 |
| `leftcat` / `rightcat`                   | string | Client Address Translation: `yes` or `no`                        |
| `leftvti` / `rightvti`                   | string | VTI IP address                                                   |
| `leftinterface-ip` / `rightinterface-ip` | string | XFRM interface IP                                                |
| `leftgroundhog` / `rightgroundhog`       | string | Groundhog Day replay testing                                     |

### Connection Type & Protocol

| Parameter     | Values                                                 | Default      | Description               |
| ------------- | ------------------------------------------------------ | ------------ | ------------------------- |
| `type`        | `tunnel`, `transport`, `passthrough`, `reject`, `drop` | `tunnel`     | Connection type           |
| `authby`      | `secret`, `rsasig`, `ecdsa`, `null`, `never`           | _(derived)_  | Authentication method     |
| `auto`        | `add`, `start`, `ondemand`, `route`, `ignore`          | `ignore`     | Connection startup action |
| `keyexchange` | `ike`, `ikev1`, `ikev2`                                | `ike` (auto) | IKE version               |
| `ikev2`       | _(obsolete)_                                           | —            | Use `keyexchange` instead |

### Cryptography

| Parameter              | Type   | Description                                     |
| ---------------------- | ------ | ----------------------------------------------- |
| `ike`                  | string | IKE SA proposal: `encryption-integrity-dhgroup` |
| `esp`                  | string | Child SA proposal: `encryption-integrity`       |
| `ah`                   | string | AH proposal (rarely used, alias for `esp`)      |
| `phase2`               | string | Legacy: `esp` or `ah`                           |
| `phase2alg`            | string | Legacy alias for `esp`                          |
| `pfs`                  | yes/no | Perfect Forward Secrecy for Child SA rekeys     |
| `esn`                  | yes/no | Extended Sequence Numbers                       |
| `sha2-truncbug`        | yes/no | SHA2-256 truncation bug compatibility (96-bit)  |
| `ms-dh-downgrade`      | yes/no | Microsoft DH downgrade workaround               |
| `pfs-rekey-workaround` | yes/no | PFS rekey workaround for buggy peers            |

### Lifetimes & Rekey

| Parameter             | Type   | Default  | Description                          |
| --------------------- | ------ | -------- | ------------------------------------ |
| `ikelifetime`         | string | `8h`     | IKE SA lifetime                      |
| `ipsec-lifetime`      | string | `8h`     | IPsec (Child) SA lifetime            |
| `ipsec-max-bytes`     | string | _(none)_ | Rekey after N bytes transferred      |
| `ipsec-max-packets`   | string | _(none)_ | Rekey after N packets transferred    |
| `rekey`               | yes/no | `yes`    | Enable SA rekeying                   |
| `reauth`              | yes/no | `no`     | Full re-authentication on rekey      |
| `rekeymargin`         | string | `9m`     | Time before expiry to start rekey    |
| `rekeyfuzz`           | string | `100%`   | Random percentage to vary rekey time |
| `retransmit-timeout`  | string | `60s`    | IKE retransmission total timeout     |
| `retransmit-interval` | string | `500ms`  | Initial IKE retransmit interval      |

### DPD (Dead Peer Detection)

| Parameter          | Type   | Default | Description        |
| ------------------ | ------ | ------- | ------------------ |
| `dpddelay`         | string | `30s`   | DPD probe interval |
| `ikev1-dpdtimeout` | string | `150s`  | IKEv1 DPD timeout  |

### Network Settings

| Parameter       | Type   | Default  | Description                                  |
| --------------- | ------ | -------- | -------------------------------------------- |
| `mtu`           | string | _(auto)_ | Override tunnel MTU                          |
| `tfc`           | string | _(none)_ | Traffic Flow Confidentiality padding size    |
| `priority`      | string | _(auto)_ | XFRM policy priority                         |
| `metric`        | string | _(none)_ | Route metric                                 |
| `reqid`         | string | _(auto)_ | SA request ID                                |
| `replay-window` | string | `32`     | Anti-replay window size                      |
| `compress`      | yes/no | `no`     | Enable IPComp compression                    |
| `encapsulation` | string | `auto`   | Force UDP encapsulation: `yes`, `no`, `auto` |
| `nopmtudisc`    | yes/no | `no`     | Disable Path MTU discovery                   |

### NAT Traversal

| Parameter          | Type   | Default  | Description                                |
| ------------------ | ------ | -------- | ------------------------------------------ |
| `nat-keepalive`    | yes/no | `yes`    | Send NAT-T keep-alive packets              |
| `nat-ikev1-method` | string | _(auto)_ | IKEv1 NAT-T method                         |
| `enable-tcp`       | string | `no`     | TCP encapsulation: `yes`, `no`, `fallback` |
| `tcp-remoteport`   | string | `4500`   | Remote TCP port for IKE-over-TCP           |

### IKE Fragmentation

| Parameter       | Type   | Default | Description                               |
| --------------- | ------ | ------- | ----------------------------------------- |
| `fragmentation` | string | `yes`   | IKEv2 fragmentation: `yes`, `no`, `force` |

### MOBIKE

| Parameter | Type   | Default | Description                    |
| --------- | ------ | ------- | ------------------------------ |
| `mobike`  | yes/no | `yes`   | Enable MOBIKE (IKEv2 mobility) |

### IP-TFS (IP Traffic Flow Security)

| Parameter              | Type   | Description               |
| ---------------------- | ------ | ------------------------- |
| `iptfs`                | yes/no | Enable IP-TFS (RFC 9347)  |
| `iptfs-fragmentation`  | string | IP-TFS fragmentation mode |
| `iptfs-packet-size`    | string | IP-TFS outer packet size  |
| `iptfs-max-queue-size` | string | Maximum IP-TFS queue size |
| `iptfs-reorder-window` | string | IP-TFS reorder window     |
| `iptfs-init-delay`     | string | IP-TFS initial delay      |
| `iptfs-drop-time`      | string | IP-TFS drop time          |

### Shunting & Failure

| Parameter          | Values                                  | Description                   |
| ------------------ | --------------------------------------- | ----------------------------- |
| `failureshunt`     | `none`, `passthrough`, `reject`, `drop` | Action when negotiation fails |
| `negotiationshunt` | `hold`, `passthrough`                   | Action during negotiation     |

### VTI (Virtual Tunnel Interface)

| Parameter       | Type   | Description                          |
| --------------- | ------ | ------------------------------------ |
| `vti-interface` | string | VTI device name                      |
| `vti-routing`   | yes/no | Let updown script handle VTI routing |
| `vti-shared`    | yes/no | Shared VTI device (disable cleanup)  |

### XFRM Interface

| Parameter         | Type   | Description       |
| ----------------- | ------ | ----------------- |
| `ipsec-interface` | string | XFRM interface ID |

### IKEv2 Redirect (RFC 5685)

| Parameter            | Type   | Description                           |
| -------------------- | ------ | ------------------------------------- |
| `send-redirect`      | string | Send redirect: `yes`, `no`, `auto`    |
| `redirect-to`        | string | Redirect target IP/FQDN               |
| `accept-redirect`    | string | Accept redirects: `yes`, `no`         |
| `accept-redirect-to` | string | Only accept redirects to this address |

### Security Labels (SELinux)

| Parameter   | Type   | Description            |
| ----------- | ------ | ---------------------- |
| `sec-label` | string | SELinux security label |

### PPK (Post-Quantum Preshared Keys)

| Parameter      | Type   | Description                        |
| -------------- | ------ | ---------------------------------- |
| `ppk`          | string | Enable PPK: `yes`, `no`, `insist`  |
| `ppk-ids`      | string | PPK identity string                |
| `intermediate` | yes/no | Enable IKEv2 Intermediate Exchange |

### Certificates & CA

| Parameter                   | Type   | Description                          |
| --------------------------- | ------ | ------------------------------------ |
| `sendca`                    | string | Send CA: `issuer`, `all`, `none`     |
| `require-id-on-certificate` | yes/no | Require peer ID to match certificate |
| `dns-match-id`              | yes/no | Use DNS to match peer ID             |

### DSCP

| Parameter    | Type   | Description                            |
| ------------ | ------ | -------------------------------------- |
| `decap-dscp` | yes/no | Copy DSCP from inner to outer on decap |
| `encap-dscp` | yes/no | Copy DSCP from inner to outer on encap |

### Misc & Interop

| Parameter                            | Type   | Default  | Description                                     |
| ------------------------------------ | ------ | -------- | ----------------------------------------------- |
| `debug`                              | string | _(none)_ | Per-connection debug flags                      |
| `also`                               | string | —        | Include another connection's params             |
| `connalias`                          | string | _(none)_ | Connection alias name(s)                        |
| `overlapip`                          | yes/no | `no`     | Allow overlapping IPsec policies                |
| `hostaddrfamily`                     | string | _(auto)_ | Address family: `ipv4`, `ipv6`                  |
| `aggressive`                         | yes/no | `no`     | IKEv1 aggressive mode                           |
| `ikepad`                             | yes/no | `yes`    | Pad IKE packets to 4 bytes                      |
| `initial-contact`                    | yes/no | `yes`    | Send Initial Contact notification               |
| `send-vendorid`                      | yes/no | `no`     | Send Libreswan vendor ID                        |
| `fake-strongswan`                    | yes/no | `no`     | Send strongSwan vendor ID (for twofish/serpent) |
| `send-esp-tfc-padding-not-supported` | yes/no | `no`     | Notify peer TFC padding is unsupported          |
| `reject-simultaneous-ike-auth`       | yes/no | `no`     | Reject simultaneous IKE_AUTH                    |
| `session-resumption`                 | yes/no | `no`     | Enable IKE Session Resumption (RFC 5723)        |
| `nflog-group`                        | string | _(none)_ | NFLOG group for this connection                 |
| `nic-offload`                        | string | `no`     | NIC ESP hardware offload: `yes`, `no`, `auto`   |
| `share-lease`                        | yes/no | `no`     | Share lease across connections                  |
| `mark`                               | string | _(none)_ | XFRM mark value                                 |
| `mark-in`                            | string | _(none)_ | Inbound XFRM mark                               |
| `mark-out`                           | string | _(none)_ | Outbound XFRM mark                              |
| `clones`                             | string | _(none)_ | RFC 9611 clones                                 |
| `narrowing`                          | yes/no | `yes`    | Allow Traffic Selector narrowing                |
| `pam-authorize`                      | yes/no | `no`     | PAM authorization check                         |
| `modecfgdns`                         | string | _(none)_ | DNS servers to push to client                   |
| `modecfgdomains`                     | string | _(none)_ | DNS domains to push to client                   |
| `modecfgbanner`                      | string | _(none)_ | Banner message for client                       |
| `modecfgpull`                        | yes/no | `yes`    | Client pulls config (vs server push)            |
| `ignore-peer-dns`                    | yes/no | `no`     | Ignore DNS from peer                            |
| `xauthby`                            | string | `file`   | XAUTH method: `file`, `pam`, `alwaysok`         |
| `xauthfail`                          | string | `hard`   | XAUTH failure: `hard`, `soft`                   |

### Cisco Interop

| Parameter          | Type   | Description                       |
| ------------------ | ------ | --------------------------------- |
| `remote-peer-type` | string | Remote peer type: `cisco`         |
| `cisco-unity`      | yes/no | Send Cisco Unity vendor ID        |
| `cisco-split`      | yes/no | Cisco split tunneling VID         |
| `nm-configured`    | yes/no | NetworkManager managed connection |

## Obsolete Parameters

These are accepted but ignored (with a warning):

| Parameter          | Replacement                              |
| ------------------ | ---------------------------------------- |
| `dpdaction`        | _(removed - always `restart` for IKEv2)_ |
| `clientaddrfamily` | `hostaddrfamily`                         |
| `keyingtries`      | _(removed - use retransmit settings)_    |
| `syslog`           | `logfile`                                |
| `plutostderrlog`   | `logfile`                                |
| `virtual_private`  | `virtual-private`                        |
| `interfaces`       | `listen`                                 |

## Parameter Aliases

| Alias                               | Canonical Name                       |
| ----------------------------------- | ------------------------------------ |
| `aggrmode`                          | `aggressive`                         |
| `keylife`, `salifetime`, `lifetime` | `ipsec-lifetime`                     |
| `dpdtimeout`                        | `ikev1-dpdtimeout`                   |
| `phase2alg`                         | `esp`                                |
| `xauthusername`                     | `username`                           |
| `policy-label`                      | `sec-label`                          |
| `send-no-esp-tfc`                   | `send-esp-tfc-padding-not-supported` |
| `curl-timeout`                      | `crl-timeout`                        |
