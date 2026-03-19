# How to Run a Single Test Suite in Libreswan

Libreswan's primary test suite relies on a KVM-based testing framework. The tests are typically defined in directories within the `testing/` folder (most notably `testing/pluto/`).

## Prerequisites (Initial Setup)

Before you can run any tests, you must ensure that the KVM testing environment is properly set up and the necessary virtual machines are created.

1. **Verify directory permissions**: Ensure that your Libreswan source directory (and its parent directories, such as your home directory) is world-readable so KVM virtual machines can mount the `testing/` directory.

2. **Establish the KVM Pool Directory**: Create the required directory (by default `/home/ubuntu/pool` assuming your work is in `/home/ubuntu/libreswan`). Alternatively, set a custom path in `testing/kvm/Makefile.inc.local`:

   ```bash
   mkdir -p /home/ubuntu/pool
   ```

   _Optional Customization (`testing/kvm/Makefile.inc.local`)_:

   ```makefile
   KVM_POOLDIR = /home/ubuntu/pool
   KVM_SOURCEDIR = /home/ubuntu/libreswan
   KVM_TESTINGDIR = /home/ubuntu/libreswan/testing
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

There are two primary methods to run a specific, individual test directory (test suite):

Before you begin, the Libreswan testing framework uses modern Python f-string syntax (nested quotes) that is only supported in **Python 3.12+**. If your system (like Ubuntu 22.04) has an older Python version, it will fail with a `SyntaxError`. You have two options to resolve this:

**Option A: Install Python 3.12 (Recommended for active development)**
You can install Python 3.12 via the `deadsnakes` PPA. Run the following:

```bash
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.12
```

_(Note: Since `make kvm-test` runs `python3` natively, you may need to update your `update-alternatives` for `python3` to point to python3.12, or run the test runner script directly using `python3.12` if you don't want to change your system defaults)._

**Option B: Patch the Python script**
If you prefer not to mess with your system's Python versions, simply patch the script's syntax to be compatible with older Python versions:

```bash
sed -i "s/f\\\"  {key}: {len(values)}: {\\\" \\\".join(values)}\\\"/f\\\"  {key}: {len(values)}: {' '.join(values)}\\\"/g" /home/ubuntu/libreswan/testing/utils/fab/stats.py
```

### Method 1: Using `make kvm-test` (Recommended)

From the `testing/kvm` directory of your Libreswan repository, you can run an individual test by specifying the `KVM_TESTS` variable and passing the **ABSOLUTE PATH** to the specific test directory.

**Warning**: Do not use relative paths (like `../pluto/ikev2-03-basic-rawrsa`) from within the `kvm/` directory or they will fail with a `FileNotFoundError`, because the underlying python testrunner script resets its internal working directory during execution.

**Syntax:**

```bash
cd testing/kvm
make kvm-test KVM_TESTS=/absolute/path/to/test/directory
```

**Example:**

```bash
cd testing/kvm
make kvm-test KVM_TESTS=/home/ubuntu/libreswan/testing/pluto/ikev2-03-basic-rawrsa
```

### Method 2: Using the `kvmrunner.py` script directly

You can use the python test runner script directly if you want more granular control or if you are already navigating within the test folders.

**Syntax (from the root directory):**

```bash
./testing/utils/kvmrunner.py path/to/test/directory
```

**Syntax (from within the test directory itself):**

```bash
cd testing/pluto/ikev2-03-basic-rawrsa
../../utils/kvmrunner.py .
```
