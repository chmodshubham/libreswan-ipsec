# How to Run a Single Test Suite in Libreswan

Libreswan's primary test suite relies on a KVM-based testing framework. The tests are typically defined in directories within the `testing/` folder (most notably `testing/pluto/`).

## Prerequisites (Initial Setup)

Before you can run any tests, you must ensure that the KVM testing environment is properly set up and the necessary virtual machines are created.

1. **Verify directory permissions**: Ensure that your Libreswan source directory (and its parent directories, such as your home directory) is world-readable so KVM virtual machines can mount the `testing/` directory.

2. **Establish the KVM Pool Directory**: The pool directory stores VM disk images. By default it is auto-detected as `../pool` relative to the source root (e.g. if source is at `~/libreswan`, the pool defaults to `~/pool`). Create it before running:

   ```bash
   mkdir -p ~/pool
   ```

   If you want a different location, set it in `testing/kvm/Makefile.inc.local`:

   ```makefile
   KVM_POOLDIR = /path/to/your/pool
   ```

3. **Install System Dependencies**: Libreswan testing requires KVM, QEMU, libvirt, and an NFS server active on your system.

   For **Ubuntu/Debian-based systems**, you install these via:

   ```bash
   sudo apt update
   sudo DEBIAN_FRONTEND=noninteractive apt install -y \
       qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst \
       python3-pexpect nfs-kernel-server libosinfo-bin
   ```

4. **Configure Access Permissions**: Add your user to the appropriate groups (`kvm`, `libvirt`). Furthermore, because KVM testing relies on QEMU, grant group write permissions to the libvirt socket directory so that `make` scripts can seamlessly trigger `virsh` and `qemu` commands:

   ```bash
   sudo usermod -aG kvm,libvirt $USER
   sudo chmod 777 /var/lib/libvirt/qemu
   ```

> [!NOTE]
> Ensure to log out and log back in (or start a new shell session) for group modifications to take effect.

5. **Install and create VMs**: Navigate to the `testing/kvm` directory and initialize the test environment by running:

   ```bash
   cd testing/kvm
   make kvm-install
   ```

   _(Alternatively, you can run `make -C testing/kvm kvm-install` from the project root)._

   This script triggers a multi-stage process that pulls the Fedora Server base ISO, unpacks it into the pool, configures the NFS mount points, and establishes standard VMs (typically named `west`, `east`, `north`, and `road`, as well as a network routing node `nic`).

> [!WARNING]
> This process takes several minutes and will download gigabytes of base images.

### KVM Virtual Machine Topologies

In Libreswan tests you will interact with the following logical systems:

- **`east` & `west`**: Security Gateways. Used to test point-to-point IPsec Site-to-Site connections.
- **`road`**: A remote "Road Warrior" end-user attempting client-to-site VPN access with a dynamic IP address.
- **`north`**: An external actor (like a Branch Office or Public DNS record).
- **`nic`**: The simulated network router / "Internet". Used to insert NAT environments or sniff simulated WAN traffic.

![libreswan-testing-topology](./images/libreswan-testing-topology.png)

_(For more details on KVM setup options, you can refer to `testing/kvm/README` and `kvmsetup.sh`)_

## Running a Single Test Suite

There are three primary methods to run a specific, individual test directory (test suite).

### Method 1: Using `./kvm check` (Quickest)

From the libreswan source root, use the `kvm` wrapper script with the test's relative path under `testing/`:

```bash
./kvm check testing/pluto/<test-name>
```

**Example:**

```bash
./kvm check testing/pluto/whack-deleteuser-01
```

This is the most convenient method for running individual tests during development.

### Method 2: Using `make kvm-test`

From the `testing/kvm` directory, pass the test path via `KVM_TESTS`. Use the **absolute path** to avoid `FileNotFoundError` (the runner resets its working directory internally):

```bash
cd testing/kvm
make kvm-test KVM_TESTS=$(realpath ../pluto/<test-name>)
```

**Example:**

```bash
cd testing/kvm
make kvm-test KVM_TESTS=$(realpath ../pluto/ikev2-03-basic-rawrsa)
```

### Method 3: Using the `kvmrunner.py` script directly

You can use the python test runner script directly if you want more granular control.

**From the source root:**

```bash
./testing/utils/kvmrunner.py testing/pluto/<test-name>
```

**From within the test directory itself:**

```bash
cd testing/pluto/<test-name>
../../utils/kvmrunner.py .
```
