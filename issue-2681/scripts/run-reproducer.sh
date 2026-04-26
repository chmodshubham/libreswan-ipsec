#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ISSUE_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ISSUE_DIR"

echo "=== issue-2681 reproducer ==="
echo ""

echo "[1/8] bringing down any previous run..."
docker compose down -v 2>/dev/null || true
rm -f logs/responder/pluto.log logs/responder/crash.txt logs/responder/before-down.txt

echo "[2/8] building image..."
docker compose build

echo "[3/8] starting containers..."
docker compose up -d

echo "[4/8] waiting for pluto daemons..."
for role in responder initiator; do
    container="issue2681-${role}"
    for i in $(seq 1 40); do
        docker logs "$container" 2>&1 | grep -q 'pluto ready' && break
        sleep 1
        [ $i -eq 40 ] && { echo "ERROR: $container pluto did not start"; docker logs "$container"; exit 1; }
    done
    echo "  $role: pluto ready"
done

# Block outbound BEFORE initiator starts.
# Responder processes IKE_SA_INIT internally (enters UNROUTED_BARE_NEGOTIATION)
# but its reply never reaches initiator, so no IKE_AUTH ever comes back.
echo "[5/8] freezing responder (DROP outbound to initiator)..."
docker exec issue2681-responder /opt/scripts/freeze-responder.sh

echo "[6/8] initiator: starting IKE handshake (responder will park in UNROUTED_BARE_NEGOTIATION)..."
docker exec -d issue2681-initiator bash -c 'ipsec auto --up client > /var/log/libreswan/up.log 2>&1'

echo "[7/8] waiting for responder to reach UNROUTED_BARE_NEGOTIATION..."
docker exec issue2681-responder /opt/scripts/wait-for-bare-negotiation.sh

echo "[8/8] triggering crash: ipsec down client on responder..."
docker exec issue2681-responder bash -c \
    'ipsec whack --showstates > /var/log/libreswan/before-down.txt 2>&1; ipsec down client 2>&1 || true'

sleep 2

echo ""
echo "=== collecting logs ==="
docker logs --tail=100 issue2681-responder > logs/responder/crash.txt 2>&1 || true

echo ""
echo "=== verdict ==="
BARE=$(grep -c 'still in UNROUTED_BARE_NEGOTIATION' logs/responder/pluto.log 2>/dev/null || true)
FATAL=$(grep -c 'FATAL: ASSERTION FAILED.*still in use' logs/responder/pluto.log 2>/dev/null || true)
STATE_SEEN=$(grep -c 'sent IKE_SA_INIT response' logs/responder/pluto.log 2>/dev/null || true)
CLEAN_DELETE=$(grep -c 'deleting connection instance' logs/responder/pluto.log 2>/dev/null || true)

if [ "$BARE" -gt 0 ] && [ "$FATAL" -gt 0 ]; then
    echo "PASS (bug present): crash reproduced"
    echo ""
    grep 'UNROUTED_BARE_NEGOTIATION\|FATAL\|ASSERTION' logs/responder/pluto.log | tail -10
    exit 0
elif [ "$STATE_SEEN" -gt 0 ] && [ "$CLEAN_DELETE" -gt 0 ]; then
    echo "FIXED: responder reached UNROUTED_BARE_NEGOTIATION state (IKE_SA_INIT seen)"
    echo "  but ipsec down completed cleanly - bug already fixed in this build"
    echo ""
    echo "State before ipsec down:"
    cat logs/responder/before-down.txt 2>/dev/null || true
    echo ""
    echo "Teardown log lines:"
    grep 'deleting\|UNROUTED\|FATAL\|routing' logs/responder/pluto.log | tail -10
    exit 0
else
    echo "SETUP FAILED: responder never reached UNROUTED_BARE_NEGOTIATION state"
    echo "  IKE_SA_INIT seen: $STATE_SEEN"
    echo ""
    echo "last 30 lines of pluto.log:"
    tail -30 logs/responder/pluto.log 2>/dev/null || echo "(no pluto.log)"
    exit 1
fi
