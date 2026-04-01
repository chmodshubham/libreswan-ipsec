# Libreswan Testing Topology

The KVM-based testing environment for Libreswan consists of a virtual network of predefined logical nodes. Each node represents a specific role within the network-such as a security gateway, a router, or an internal client endpoint. Understanding the network topology and interface assignments is essential for analyzing test outputs and developing new test cases.

Refer [Libreswan Wiki: Testing Topology](https://github.com/libreswan/libreswan/wiki/Testing:-Topology).

![Testing Topology Diagram](./images/libreswan-testing-topology.png)

View diagram in draw.io: [Link](https://drive.google.com/file/d/1_aYAc-WE4zy-yXtxBCbS_8DI-78atBiw/view?usp=sharing) (comment only)

## 1. Node Roles and Identifiers

The testing topology comprises seven primary machines, divided into three functional categories:

### Security Gateways

These nodes execute the Libreswan daemon (Pluto) to negotiate IPsec tunnels.

- **East (23)**: The primary right-hand gateway; typically acts as the responder in IKE negotiations.
- **West (45)**: The primary left-hand gateway; typically acts as the initiator in IKE negotiations.
- **North (33)**: An auxiliary gateway utilized for complex multi-peer configurations.
- **Road (209)**: A dynamic "road warrior" client deployed for testing remote access VPN scenarios.

### Routing Infrastructure

- **Nic (254)**: The simulated internet router bridging the Wide Area Network (WAN) segments together, enabling connectivity between the gateways.

### Internal Test Endpoints

These nodes serve as target endpoints. In standard gateway tests, they act as unencrypted plaintext sources behind the security gateways. In direct connection tests, they act as native cryptographic endpoints themselves.

- **Rise (12)**: The internal client endpoint situated behind East.
- **Set (15)**: The internal client endpoint situated behind West.

> [!NOTE]
> The numerical identifiers assigned above (e.g., `North=33`, `Road=209`) mathematically dictate the IP addresses within the framework's `198.18.N.N/24` benchmark subnet. This rule applies globally to all nodes: any machine dynamically generating a virtual IPsec overlay tunnel receives its corresponding `198.18.N.N` endpoint explicitly.

## 2. Network Topology Structure

The simulated network environment utilizes several IPv4 and IPv6 subnets to represent the internal LANs and the external WAN.

### WAN Segments (Public IPs)

Connected via the `nic` router, enabling gateways to communicate.

| Network Subnet | Associated Nodes | IPv6 Equivalent     |
| -------------- | ---------------- | ------------------- |
| `192.1.2.0/24` | East, West, Nic  | `2001:db8:1:2::/64` |
| `192.1.3.0/24` | North, Road, Nic | `2001:db8:1:3::/64` |

### LAN Segments (Private IPs)

The private subnets protected behind the security gateways, plus the direct IPsec testbed.

| Network Subnet  | Associated Nodes        | IPv6 Equivalent     |
| --------------- | ----------------------- | ------------------- |
| `192.0.1.0/24`  | West (.254), Set (.15)  | `2001:db8:0:1::/64` |
| `192.0.2.0/24`  | East (.254), Rise (.12) | `2001:db8:0:2::/64` |
| `192.0.3.0/24`  | North (.254)            | `2001:db8:0:3::/64` |
| `198.18.1.0/24` | Rise (.12), Set (.15)   | `2001:db8:1::/64`   |

### Management Network

All nodes maintain an interface natively bound to `198.19.0.0/16` (`swandefault`) for Out-Of-Band (OOB) provisioning and NFS access, physically isolating management traffic from test metrics.

## 3. Node Interface Configurations

### 3.1. Security Gateways

#### East Node (Gateway)

- **`eth0`**
  - **IP Address**: `192.0.2.254/24` (IPv6: `2001:db8:0:2::254/64`)
  - **Virtual Bridge**: `192_0_2`
  - **Connects To**: The internal LAN segment behind East. Functionally bridges East directly to the **`rise`** client endpoint to test protected corporate traffic egressing the gateway.
- **`eth1`**
  - **IP Address**: `192.1.2.23/24` (IPv6: `2001:db8:1:2::23/64`)
  - **Virtual Bridge**: `192_1_2`
  - **Connects To**: The primary Public WAN segment (the "Internet"). This bridge connects East to the **`nic`** router, and through `nic`, over to the internet-facing interface of **`west`**.
- **`eth2`**
  - **IP Address**: DHCP assigned (`198.19.0.0/16` subnet)
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The isolated Out-Of-Band (OOB) management and NFS provisioning network shared by all nodes in the test suite independently of the routing testbed.
- **`ipsec`** (Virtual Tunnel)
  - **IP Address**: `198.18.23.23/24`
  - **Connects To**: The virtual "IPsec Overlay Network" (Linux XFRM Stack). This is not a physical switch connection; rather, any packets routed into this interface are mathematically encrypted by the kernel before being transmitted physically over the normal WAN (`eth1`) connection to West.

#### West Node (Gateway)

- **`eth0`**
  - **IP Address**: `192.0.1.254/24` (IPv6: `2001:db8:0:1::254/64`)
  - **Virtual Bridge**: `192_0_1`
  - **Connects To**: The internal LAN segment behind West. Bridges West directly to the **`set`** client endpoint, protecting traffic sourced from it.
- **`eth1`**
  - **IP Address**: `192.1.2.45/24` (IPv6: `2001:db8:1:2::45/64`)
  - **Virtual Bridge**: `192_1_2`
  - **Connects To**: The primary Public WAN segment. Links West securely to the **`nic`** router, establishing its outward connection toward **`east`**.
- **`eth2`**
  - **IP Address**: DHCP assigned
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The shared OOB management network.
- **`ipsec`** (Virtual Tunnel)
  - **IP Address**: `198.18.45.45/24`
  - **Connects To**: The virtual "IPsec Overlay Network" (Linux XFRM Stack). Packets routed into this software interface are encrypted and encapsulated before being forwarded physically over the normal WAN (`eth1`) connection to East.

#### North Node (Auxiliary Gateway)

- **`eth0`**
  - **IP Address**: `192.0.3.254/24` (IPv6: `2001:db8:0:3::254/64`)
  - **Virtual Bridge**: `192_0_3`
  - **Connects To**: The internal LAN segment behind North.
- **`eth1`**
  - **IP Address**: `192.1.3.33/24` (IPv6: `2001:db8:1:3::33/64`)
  - **Virtual Bridge**: `192_1_3`
  - **Connects To**: The secondary Public WAN segment. Links North directly to the **`road`** client and the **`nic`** router to validate independent network clusters or cross-wan routing.
- **`eth2`**
  - **IP Address**: DHCP assigned
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The shared OOB management network.
- **`ipsec`** (Virtual Tunnel)
  - **IP Address**: `198.18.33.33/24`
  - **Connects To**: The virtual "IPsec Overlay Network" (Linux XFRM Stack). Packets routed into this software interface are logically encrypted before executing over the ordinary WAN (`eth1`) connection to evaluate complex multi-gateway routing.

### 3.2. Remote Test Clients

#### Road Node (Mobile Endpoint)

- **`eth0`**
  - **IP Address**: `192.1.3.209/24` (IPv6: `2001:db8:1:3::209/64`)
  - **Virtual Bridge**: `192_1_3`
  - **Connects To**: The secondary Public WAN internet segment. Connects the stateless road-warrior client to the internet router (**`nic`**) and structurally neighbors the **`north`** gateway, although its typical testbed goal is initiating remote connection traversal targeting `east` or `west`.
- **`eth1`**
  - **IP Address**: DHCP assigned
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The shared OOB management network.
- **`ipsec`** (Virtual Tunnel)
  - **IP Address**: `198.18.209.209/24`
  - **Connects To**: The virtual "IPsec Overlay Network" (Linux XFRM Stack), instantiated dynamically when the road warrior client successfully establishes a secure remote-access tunnel targeting `East` or `West`.

### 3.3. Internal LAN Endpoints

#### Rise Node (Test Target Endpoint)

- **`eth0`**
  - **IP Address**: `198.18.1.12/24` (IPv6: `2001:db8:1::12/64`)
  - **Virtual Bridge**: `198_18_1` ("Direct IPsec Testbed")
  - **Connects To**: A dedicated, out-of-band wire that completely bypasses the `East` and `West` gateways. It functionally links the **`rise`** client securely and directly to the **`set`** client for specific, native "Host-to-Host" IPsec connection testing.
- **`eth1`**
  - **IP Address**: `192.0.2.12/24` (IPv6: `2001:db8:0:2::12/64`)
  - **Virtual Bridge**: `192_0_2`
  - **Connects To**: The private internal LAN hosted behind the **`east`** gateway. Serves effectively as the protected private machine receiving/decapsulating payload from `set`.
- **`eth2`**
  - **IP Address**: DHCP assigned
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The shared OOB management network.
- **`ipsec`** (Virtual Tunnel)
  - **IP Address**: `198.18.12.12/24`
  - **Connects To**: The virtual "IPsec Overlay Network" (Linux XFRM Stack) utilized exclusively when `Rise` generates its own native IPsec encryption over the `198_18_1` testbed bridge (instead of relying on the `East` gateway).

#### Set Node (Test Origin Endpoint)

- **`eth0`**
  - **IP Address**: `198.18.1.15/24` (IPv6: `2001:db8:1::15/64`)
  - **Virtual Bridge**: `198_18_1` ("Direct IPsec Testbed")
  - **Connects To**: The dedicated point-to-point test connection bypassing gateways to physically link **`set`** directly to **`rise`** for internal "Host-to-Host" encryption test cases.
- **`eth1`**
  - **IP Address**: `192.0.1.15/24` (IPv6: `2001:db8:0:1::15/64`)
  - **Virtual Bridge**: `192_0_1`
  - **Connects To**: The private internal LAN hosted behind the **`west`** gateway. Frequently utilized to source ICMP/payload verification traffic destined externally payload for `rise`.
- **`eth2`**
  - **IP Address**: DHCP assigned
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The shared OOB management network.
- **`ipsec`** (Virtual Tunnel)
  - **IP Address**: `198.18.15.15/24`
  - **Connects To**: The virtual "IPsec Overlay Network" (Linux XFRM Stack) utilized locally by `Set` only when executing native IPsec encryptions across the `198_18_1` bypass bridge.

### 3.4. Routing Infrastructure

#### Nic Node (Simulated Internet Router)

- **`eth1`**
  - **IP Address**: `192.1.2.254/24` (IPv6: `2001:db8:1:2::254/64`)
  - **Virtual Bridge**: `192_1_2`
  - **Connects To**: The primary Public WAN segment. Evaluates routing rules allowing internet communication strictly between the **`east`** and **`west`** gateway public IPs.
- **`eth2`**
  - **IP Address**: `192.1.3.254/24` (IPv6: `2001:db8:1:3::254/64`)
  - **Virtual Bridge**: `192_1_3`
  - **Connects To**: The secondary Public WAN segment. Intercepts traffic destined for/sourced from the **`north`** gateway and the stateless **`road`** clients. Internally translates paths allowing packets originating from `road` to traverse this bridge over to `eth1` and access `east`.
- **`eth0`**
  - **IP Address**: DHCP assigned
  - **Virtual Bridge**: `swandefault`
  - **Connects To**: The shared OOB management network natively enabling file syncing for the framework tests across environments without poisoning the test metrics.

## 4. Primary Core Scenarios

The test framework evaluates several fundamental baseline connectivity scenarios before applying specific payload or cryptographic constraints.

### Scenario 1: Subnet-to-Subnet (Site-to-Site)

Validates that two disparate private LAN networks communicate securely over public routing infrastructure.

- **Participating Nodes:** `Set`, `West`, `Nic`, `East`, `Rise`
- **Execution Flow:** `West` initiates the connection to `East` across the WAN segment. Once the IPsec Security Association is established, unencrypted traffic from `Set` (`192.0.1.15`) is routed to `Rise` (`192.0.2.12`). `West` automatically encapsulates this traffic over the virtual tunnel, where `East` decapsulates and routes it internally to `Rise`.

### Scenario 2: Host-to-Host

Secures node-to-node operational links directly between two peering security gateways, abstracting LANs.

- **Participating Nodes:** `West`, `Nic`, `East`
- **Execution Flow:** `West` initiates the IKE tunnel directly targeting `East`'s public interface IP (`192.1.2.45` ↔ `192.1.2.23`) without advertising `leftsubnet` or `rightsubnet` definitions. The endpoints encrypt only traffic generated strictly between their respective static IP interfaces.

### Scenario 3: Road Warrior (Remote Access)

Simulates a mobile endpoint traversing untrusted public infrastructure utilizing an assigned virtual IP address.

- **Participating Nodes:** `Road`, `Nic`, `East`
- **Execution Flow:** The `Road` client reaches `East` via the internet `Nic` layer. Upon `IKE_AUTH`, `East` pushes local configuration parameters down to the client utilizing a Configuration Payload (CP), dynamically leasing an internal IP (e.g., `192.0.2.100`) from an internal address pool to `Road`. Tunnel policies automatically bind to this leased address.

### Scenario 4: Tri-Gateway Configuration (North Node)

Validates interactions involving a third, independent security peer outside of the standard East-West dual architecture.

- **Participating Nodes:** `North`, `Nic`, `East`, `West`
- **Execution Flow:** Evaluates tests involving multi-peer connections or topological switches, such as `North` initiating IKE negotiation to `East` via inter-subnet WAN transitions (`192.1.3.254` → `192.1.2.254`). Validates redirect functionalities or three-way hub-and-spoke deployments.
