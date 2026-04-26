# issue-2681: `ipsec down` FATAL assertion reproducer

Reproduces the crash from [issue #2681](https://github.com/libreswan/libreswan/issues/2681):

```
EXPECTATION FAILED: "client"[2] 172.29.0.20: connection $3 [...] still in UNROUTED_BARE_NEGOTIATION
FATAL: ASSERTION FAILED: "client"[2] 172.29.0.20: connection $3 [...] still in use
```

## How it works

Two containers (responder + initiator) on `172.29.0.0/24`. The responder uses `right=%any` (creates connection instances). Before the initiator's IKE_AUTH packet can arrive, `iptables` drops it — parking the responder in `UNROUTED_BARE_NEGOTIATION` forever. Then `ipsec down client` is run on the responder, triggering the crash.

## Quickstart

```bash
cd /home/ubuntu/libreswan-ipsec/issue-2681
./scripts/run-reproducer.sh
```

First run builds libreswan from `/home/ubuntu/libreswan` source (~5 min). Subsequent runs reuse the image cache.

Expected output ends with:
```
PASS: crash reproduced
```

## Inspect the crash

```bash
# pluto debug log (full trace)
cat logs/responder/pluto.log | grep -A2 'UNROUTED_BARE_NEGOTIATION\|FATAL'

# docker stdout (includes "=== PLUTO EXITED ===" banner)
cat logs/responder/crash.txt

# state snapshot taken just before ipsec down
cat logs/responder/before-down.txt
```

## Attach gdb (container stays alive after crash)

```bash
docker exec -it issue2681-responder bash
gdb /usr/local/libexec/ipsec/pluto /var/log/libreswan/core.pluto.*
(gdb) bt
```

## Test a fix

Edit the source files in `/home/ubuntu/libreswan/`, then:

```bash
# rebuild responder image only
docker compose build responder

# re-run; crash lines should be absent
./scripts/run-reproducer.sh
# expected: MISMATCH (no crash = fix works)
```

Fix sites identified in `../../../libreswan/issue2681.md`:
- `programs/pluto/whack_down.c` line ~339 (`VISIT_CONNECTION_CHILDLESS_PRINCIPAL_IKE_SA`)
- `programs/pluto/routing.c` line ~1167 (`teardown_ike_dispatch_ok`)

## Reset

```bash
docker compose down -v
rm -f logs/responder/pluto.log logs/initiator/pluto.log logs/responder/crash.txt
```
