#!/bin/sh
# Block IKE_AUTH from initiator. Must run AFTER IKE_SA_INIT has completed.
# After IKE_SA_INIT both sides float to UDP/4500 (NAT-T). Block that.
# Also block UDP/500 as safety net.
iptables -I INPUT -p udp -s 172.29.0.20 --dport 4500 -j DROP
iptables -I INPUT -p udp -s 172.29.0.20 --dport 500  -j DROP
echo "freeze: iptables rules installed, IKE_AUTH from initiator will be dropped"
