# Libreswan Testing Topology

The KVM-based testing environment for Libreswan consists of a virtual network of predefined logical nodes. Each node represents a specific role within the network—such as a security gateway, a router, or an internal client endpoint. Understanding the network topology and interface assignments is essential for analyzing test outputs and developing new test cases.

Refer [Libreswan Wiki: Testing Topology](https://github.com/libreswan/libreswan/wiki/Testing:-Topology).

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

### Internal Clients

These nodes serve as plaintext traffic endpoints located behind the security gateways to validate subnet-to-subnet tunnel routing. They do not run the Libreswan daemon.

- **Rise (12)**: The internal client endpoint situated behind East.
- **Set (15)**: The internal client endpoint situated behind West.

> [!NOTE]
> The numerical identifiers assigned above correspond to the `198.18.N.N/24` subnet configuration used natively by IPsec virtual tunnel interfaces during tests.

## 2. Network Topology Structure

The simulated network environment utilizes several IPv4 and IPv6 subnets to represent the internal LANs and the external WAN.

### WAN Segments (Public IPs)

Connected via the `nic` router, enabling gateways to communicate.

| Network Subnet | Associated Nodes | IPv6 Equivalent     |
| -------------- | ---------------- | ------------------- |
| `192.1.2.0/24` | East, West, Nic  | `2001:db8:1:2::/64` |
| `192.1.3.0/24` | North, Road, Nic | `2001:db8:1:3::/64` |

### LAN Segments (Private IPs)

The private subnets protected behind the security gateways.

| Network Subnet | Associated Nodes        | IPv6 Equivalent     |
| -------------- | ----------------------- | ------------------- |
| `192.0.1.0/24` | West (.254), Set (.15)  | `2001:db8:0:1::/64` |
| `192.0.2.0/24` | East (.254), Rise (.12) | `2001:db8:0:2::/64` |
| `192.0.3.0/24` | North (.254)            | `2001:db8:0:3::/64` |

### Management Network

All nodes maintain an interface on `198.19.0.0/16` (`swandefault`) for Out-Of-Band (OOB) provisioning and NFS access, isolating management traffic from test metrics.

## 3. Node Interface Configurations

### East Gateway

| Interface | Subnet Bridge | IP Address       | Role                           |
| --------- | ------------- | ---------------- | ------------------------------ |
| `eth0`    | `192_0_2`     | `192.0.2.254/24` | LAN Gateway                    |
| `eth1`    | `192_1_2`     | `192.1.2.23/24`  | WAN Interface (Faces West/Nic) |
| `eth2`    | `swandefault` | DHCP             | Management Network             |

### West Gateway

| Interface | Subnet Bridge | IP Address       | Role                           |
| --------- | ------------- | ---------------- | ------------------------------ |
| `eth0`    | `192_0_1`     | `192.0.1.254/24` | LAN Gateway                    |
| `eth1`    | `192_1_2`     | `192.1.2.45/24`  | WAN Interface (Faces East/Nic) |
| `eth2`    | `swandefault` | DHCP             | Management Network             |

### Nic Router

| Interface | Subnet Bridge | IP Address       | Role                                |
| --------- | ------------- | ---------------- | ----------------------------------- |
| `eth0`    | `swandefault` | DHCP             | Management Network                  |
| `eth1`    | `192_1_2`     | `192.1.2.254/24` | Primary WAN Router (East ↔ West)    |
| `eth2`    | `192_1_3`     | `192.1.3.254/24` | Secondary WAN Router (North ↔ Road) |

### North Gateway

| Interface | Subnet Bridge | IP Address       | Role                           |
| --------- | ------------- | ---------------- | ------------------------------ |
| `eth0`    | `192_0_3`     | `192.0.3.254/24` | LAN Gateway                    |
| `eth1`    | `192_1_3`     | `192.1.3.33/24`  | WAN Interface (Faces Road/Nic) |
| `eth2`    | `swandefault` | DHCP             | Management Network             |

### Road Client

| Interface | Subnet Bridge | IP Address       | Role                            |
| --------- | ------------- | ---------------- | ------------------------------- |
| `eth0`    | `192_1_3`     | `192.1.3.209/24` | WAN Interface (Faces North/Nic) |
| `eth2`    | `swandefault` | DHCP             | Management Network              |

### Rise Endpoint

| Interface | Subnet Bridge | IP Address       | Role                     |
| --------- | ------------- | ---------------- | ------------------------ |
| `eth0`    | `198_18_1`    | `198.18.1.12/24` | Fixed Testing Endpoint   |
| `eth1`    | `192_0_2`     | `192.0.2.12/24`  | LAN Client (Behind East) |
| `eth2`    | `swandefault` | DHCP             | Management Network       |

### Set Endpoint

| Interface | Subnet Bridge | IP Address       | Role                     |
| --------- | ------------- | ---------------- | ------------------------ |
| `eth0`    | `198_18_1`    | `198.18.1.15/24` | Fixed Testing Endpoint   |
| `eth1`    | `192_0_1`     | `192.0.1.15/24`  | LAN Client (Behind West) |
| `eth2`    | `swandefault` | DHCP             | Management Network       |

> [!NOTE]
> Virtual IPsec tunnel interfaces instantiated dynamically during test execution are assigned IPs within the `198.18.N.N/24` subnet block. These do not statically appear on the base Ethernet tables of the gateways.

## 4. Primary Core Scenarios

The test framework evaluates several fundamental baseline connectivity scenarios before applying specific payload or cryptographic constraints.

### Scenario 1: Subnet-to-Subnet (Site-to-Site)

Validates that two disparate private LAN networks communicate securely over public routing infrastructure.

- **Participating Nodes:** `Set`, `West`, `Nic`, `East`, `Rise`
- **Execution Flow:** `West` initiates the connection to `East` across the WAN segment. Once the IPsec Security Association is established, unencrypted traffic from `Set` (`192.0.1.15`) is routed to `Rise` (`192.0.2.12`). `West` automatically encapsulates this traffic over the tunnel, where `East` decapsulates and routes it internally to `Rise`.

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
