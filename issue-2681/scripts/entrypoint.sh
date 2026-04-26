#!/bin/bash
set -e

ulimit -c unlimited 2>/dev/null || true

# best-effort: may be read-only on kernels that share core_pattern with host
echo '/var/log/libreswan/core.%e.%p' > /proc/sys/kernel/core_pattern 2>/dev/null || true

mkdir -p /run/pluto /var/log/libreswan

# load connection config
ipsec addconn --config /etc/ipsec.conf --checkconfig 2>&1 | tee /var/log/libreswan/addconn.log || true

echo "=== starting pluto ==="
ipsec pluto --nofork --stderrlog --logfile=/var/log/libreswan/pluto.log &
PLUTO_PID=$!

# wait for pluto socket
for i in $(seq 1 30); do
    [ -S /run/pluto/pluto.ctl ] && break
    sleep 0.5
done

echo "=== pluto ready (pid=$PLUTO_PID) ==="

# load connections
ipsec auto --add client 2>&1 || true

wait $PLUTO_PID
EXIT=$?
echo "=== PLUTO EXITED (exit=$EXIT) ==="
ls -la /var/log/libreswan/ 2>/dev/null || true

# keep container alive so user can docker exec in for gdb / log inspection
tail -f /dev/null
