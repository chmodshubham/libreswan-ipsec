# libreswan-ipsec

IPsec tunnel setup using [Libreswan](https://libreswan.org/) on Ubuntu, built from source.

This repo has ready-to-use configs for two scenarios:

1. **Single-server test** - two Docker containers talking to each other over IPsec on one machine
2. **Two-server tunnel** - a proper site-to-site IPsec tunnel between two Ubuntu boxes

Both use PSK authentication with AES-256 + SHA-256.

> [!NOTE]
> For all supported algorithms and config syntax, see [ALGORITHM_REFERENCE.md](docs/ALGORITHM_REFERENCE.md) and edit configs accordingly.

## Prerequisites

Ubuntu 22.04 or later. Install build dependencies:

```bash
sudo apt update
sudo apt install -y build-essential pkg-config \
  bison flex libnss3-dev libnss3-tools libevent-dev \
  libunbound-dev libpam0g-dev libcap-ng-dev \
  libldns-dev xmlto libcurl4-openssl-dev
```

## Build & install Libreswan

```bash
git clone https://github.com/libreswan/libreswan.git
cd libreswan

# compile libreswan
make base

# install binaries to /usr/local
sudo make install-base

# create the NSS certificate database
sudo ipsec initnss

# start the pluto IKE daemon
sudo ipsec start
```

Verify it's running:

```bash
sudo ipsec status
# should say "pluto is running"
```

### Known Issues

If you encounter the error `error: 'edKey' undeclared`, it indicates that your current NSS (Network Security Services) version does not support EdDSA.

You have two options to resolve it:

**Option 1:** Disable EdDSA support

```bash
echo "USE_EDDSA=false" > Makefile.inc.local
```

> [!NOTE]
> For a full list of build flags, see [BUILD_FLAGS.md](docs/BUILD_FLAGS.md).

**Option 2:** Upgrade NSS (>=3.99 which includes edDSA support)

## 1. Single-server test (Docker)

This runs two containers on a bridge network and sets up a tunnel between them.

> [!NOTE]
> Requires Docker and Docker Compose.

**Stage the binaries into the Docker build context:**

```bash
sudo make DESTDIR=/tmp/libreswan-staging install-base
sudo cp -a /tmp/libreswan-staging/usr/local/ single-server/staging/usr/local/
sudo chown -R $(id -u):$(id -g) single-server/staging/
```

**Set a PSK:**

```bash
PSK=$(openssl rand -hex 32)
sed -i "s/REPLACE_PSK_HERE/$PSK/" \
  single-server/configs/site-a/ipsec.secrets \
  single-server/configs/site-b/ipsec.secrets
```

**Build & run:**

```bash
cd single-server
docker compose build
docker compose up -d
```

**Check it worked:**

```bash
docker logs ipsec-site-a 2>&1 | grep established
docker exec ipsec-site-a ping -c 3 172.28.0.20
docker exec ipsec-site-a ipsec trafficstatus
```

You should see `established IKE SA`, pings going through, and active traffic counters.

**Tear down:**

```bash
docker compose down
```

---

## 2. Two-server tunnel

Template configs live in `two-server/server-a/` and `two-server/server-b/`. Each server considers itself `left`.

**On both servers:** complete the build steps above, then enable forwarding:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
```

**Generate a PSK** on one server:

```bash
openssl rand -hex 32
```

**Deploy configs** - on Server A:

```bash
sudo cp server-a/ipsec.conf /etc/ipsec.d/site-to-site.conf
sudo cp server-a/ipsec.secrets /etc/ipsec.d/site-to-site.secrets
```

Edit both files: replace `A.A.A.A` and `B.B.B.B` with real IPs, `REPLACE_PSK_HERE` with your PSK. Then:

```bash
sudo chmod 600 /etc/ipsec.d/site-to-site.secrets
```

Do the same on Server B using `server-b/` configs.

**Open firewall ports** (if applicable):

```bash
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw allow proto esp
```

**Start the tunnel** on both servers:

```bash
sudo ipsec restart
```

The tunnel auto-starts (`auto=start` is set in the configs).

**Verify:**

```bash
sudo ipsec trafficstatus
ping -c 4 192.168.2.1              # from Server A
sudo tcpdump -i eth0 -c 5 esp      # should see ESP packets
```

**Persist across reboots:**

```bash
sudo systemctl enable ipsec.service
```

---

## Troubleshooting

```bash
sudo ipsec status              # full status dump
sudo ipsec trafficstatus       # active tunnels
sudo ip xfrm state             # kernel SA table
sudo journalctl -u ipsec -f    # live logs
```
