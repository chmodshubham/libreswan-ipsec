#!/bin/sh
# Confirm responder has a connection instance waiting for IKE_AUTH (UNROUTED_BARE_NEGOTIATION).
# IKE_SA_INIT response sent + no established IKE SA = parked in that state.
LOGFILE=/var/log/libreswan/pluto.log
TIMEOUT=15
i=0
echo "wait-for-bare-negotiation: confirming parked state..."
while [ $i -lt $TIMEOUT ]; do
    if grep -q 'sent IKE_SA_INIT response' "$LOGFILE" 2>/dev/null && \
       ! grep -q 'established IKE SA' "$LOGFILE" 2>/dev/null; then
        echo "wait-for-bare-negotiation: responder in UNROUTED_BARE_NEGOTIATION (IKE_SA_INIT done, no established SA)"
        exit 0
    fi
    sleep 1
    i=$((i+1))
done
echo "wait-for-bare-negotiation: TIMEOUT after ${TIMEOUT}s"
cat "$LOGFILE" 2>/dev/null | tail -20
exit 1
