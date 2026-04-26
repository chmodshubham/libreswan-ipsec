FROM ubuntu:22.04 AS builder

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential pkg-config bison flex \
    libnss3-dev libnss3-tools libevent-dev \
    libunbound-dev libpam0g-dev libcap-ng-dev \
    libldns-dev xmlto libcurl4-openssl-dev \
    libseccomp-dev gdb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src/libreswan
COPY . .

# Ubuntu 22.04 NSS too old for EdDSA; -O0 -g3 preserve assertion + symbols
RUN printf 'USE_EDDSA=false\nWERROR_CFLAGS=\nUSERLAND_CFLAGS+=-O0 -g3 -ggdb\n' \
    > Makefile.inc.local && \
    mkdir -p testing && \
    printf '.DEFAULT:\n\t@true\n' > testing/Makefile && \
    make base && \
    make install-base DESTDIR=/staging

# -----------------------------------------------------------------------
FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    iproute2 iputils-ping iptables \
    libnss3 libnss3-tools libunbound8 \
    libevent-core-2.1-7 libevent-pthreads-2.1-7 \
    libldns3 libcurl4 libcap-ng0 libpam0g \
    procps tcpdump libsystemd0 gdb && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /staging/usr/local /usr/local

RUN mkdir -p /run/pluto /var/lib/ipsec/nss /etc/ipsec.d \
             /var/log/libreswan && \
    certutil -N -d sql:/var/lib/ipsec/nss --empty-password

# Scripts embedded inline — build context is libreswan source root,
# so we cannot COPY from outside it.
RUN mkdir -p /opt/scripts

RUN cat > /opt/scripts/entrypoint.sh << 'SCRIPT'
#!/bin/bash
set -e

ulimit -c unlimited 2>/dev/null || true
echo '/var/log/libreswan/core.%e.%p' > /proc/sys/kernel/core_pattern 2>/dev/null || true
mkdir -p /run/pluto /var/log/libreswan

echo "=== starting pluto ==="
ipsec pluto --nofork --logfile=/var/log/libreswan/pluto.log &
PLUTO_PID=$!

for i in $(seq 1 30); do
    [ -S /run/pluto/pluto.ctl ] && break
    sleep 0.5
done

echo "=== pluto ready (pid=$PLUTO_PID) ==="
ipsec auto --add client 2>&1 || true

wait $PLUTO_PID
EXIT=$?
echo "=== PLUTO EXITED (exit=$EXIT) ==="
ls -la /var/log/libreswan/ 2>/dev/null || true
tail -f /dev/null
SCRIPT

RUN cat > /opt/scripts/freeze-responder.sh << 'SCRIPT'
#!/bin/sh
# Block OUTBOUND IKE from responder to initiator.
# Responder processes IKE_SA_INIT internally (enters UNROUTED_BARE_NEGOTIATION)
# but its reply never reaches initiator, so initiator never sends IKE_AUTH.
# Must be installed BEFORE initiator starts.
iptables -I OUTPUT -p udp -d 172.29.0.20 --dport 500  -j DROP
iptables -I OUTPUT -p udp -d 172.29.0.20 --dport 4500 -j DROP
echo "freeze: OUTPUT rules installed, responder replies to initiator will be dropped"
SCRIPT

RUN cat > /opt/scripts/wait-for-bare-negotiation.sh << 'SCRIPT'
#!/bin/sh
LOGFILE=/var/log/libreswan/pluto.log
TIMEOUT=15
i=0
echo "wait-for-bare-negotiation: confirming parked state..."
while [ $i -lt $TIMEOUT ]; do
    if grep -q 'sent IKE_SA_INIT response' "$LOGFILE" 2>/dev/null && \
       ! grep -q 'established IKE SA' "$LOGFILE" 2>/dev/null; then
        echo "wait-for-bare-negotiation: responder in UNROUTED_BARE_NEGOTIATION"
        exit 0
    fi
    sleep 1
    i=$((i+1))
done
echo "wait-for-bare-negotiation: TIMEOUT after ${TIMEOUT}s"
tail -20 "$LOGFILE" 2>/dev/null
exit 1
SCRIPT

RUN chmod +x /opt/scripts/*.sh

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
