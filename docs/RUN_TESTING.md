# How to Run a Single Test Suite in Libreswan

Libreswan's primary test suite relies on a KVM-based testing framework. The tests are typically defined in directories within the `testing/` folder (most notably `testing/pluto/`).

## Prerequisites (Initial Setup)

Before you can run any tests, you must ensure that the KVM testing environment is properly set up and the necessary virtual machines are created.

1. **Verify directory permissions**: Ensure that your Libreswan source directory (and its parent directories, such as your home directory) is world-readable so KVM virtual machines can mount the `testing/` directory.

2. **Establish the KVM Pool Directory**: The pool directory stores VM disk images. By default it is auto-detected as `../pool` relative to the source root (e.g. if source is at `~/libreswan`, the pool defaults to `~/pool`). Create it before running:

   ```bash
   mkdir -p ~/pool
   ```

   If you want a different location, set it in `Makefile.inc.local` (create an empty file if needed in the libreswan root):

   ```makefile
   KVM_POOLDIR = /path/to/your/pool
   ```

3. **Install System Dependencies**: Libreswan testing requires KVM, QEMU, libvirt, and an NFS server active on your system.

   For **Fedora-based systems** (Recommended), you install these via:

   ```bash
   sudo dnf update
   sudo dnf install -y make git gitk patch xmlto python3-pexpect curl tar \
       qemu virt-install libvirt-daemon-kvm libvirt-daemon-qemu dvd+rw-tools \
       nfs-utils nss-devel
   ```

   For **Debian/Ubuntu-based systems**, you install these via:

   ```bash
   sudo apt update
   sudo DEBIAN_FRONTEND=noninteractive apt install -y \
       make git gitk xmlto python3-pexpect curl tar virtinst libvirt-clients \
       libvirt-daemon libvirt-daemon-system libvirt-daemon-driver-qemu \
       qemu-system-x86 dvd+rw-tools nfs-kernel-server rpcbind
   ```

4. **Configure Access Permissions**: Add your user to the appropriate groups (`kvm`, `libvirt`). Furthermore, because KVM testing relies on QEMU, grant group write permissions to the libvirt socket directory so that `make` scripts can seamlessly trigger `virsh` and `qemu` commands:

   For Fedora:

   ```bash
   sudo usermod -a -G $(stat --format %G /var/lib/libvirt/qemu) $USER
   sudo usermod -a -G $(stat --format %G /dev/kvm) $USER
   sudo chmod g+w /var/lib/libvirt/qemu
   ```

   For Debian/Ubuntu:

   ```bash
   sudo usermod -aG kvm,libvirt $USER
   sudo chmod g+w /var/lib/libvirt/qemu
   ```

> [!NOTE]
> Ensure to log out and log back in (or start a new shell session) for group modifications to take effect. You must also ensure that `root` can access the build directory (e.g., `chmod a+x $HOME`).

5. **Install and create VMs**: From the libreswan project root, initialize the test environment by running:

   ```bash
   ./kvm install
   ```

> [!WARNING]
> This process takes several minutes and will download gigabytes of base images.

This top-level script triggers a multi-stage process that pulls the Fedora Server base ISO, unpacks it into the pool, configures the NFS mount points, and establishes the standard VMs (typically named `west`, `east`, `north`, `road`, `rise`, `set`, and the network routing node `nic`).

Learn more about the [Libreswan Testing Topology](./TESTING_TOPOLOGY.md).

## Running the Test Suite

There are several options to run tests using the top-level `./kvm` script:

### Running a specific test (Single-test mode)

From the libreswan source root, use the `kvm` wrapper script with the test's relative path under `testing/`:

```bash
./kvm check testing/pluto/<test-name>
```

**Example:**

```bash
./kvm check testing/pluto/whack-deleteuser-01
```

By default, single-test mode skips post-mortem steps (like shutting down Pluto or destroying VMs) so you can log in and debug. To force post-mortem in single-test mode, add `-pm`:

```bash
./kvm check -pm testing/pluto/<test-name>
```

### Running multiple tests or rechecking

Run all tests:

```bash
./kvm check
```

Run tests, but skip tests that already passed:

```bash
./kvm recheck
```

Display results or differences:

```bash
./kvm results
./kvm diffs
```

### Combining commands

You can combine multiple operations on a single line:

```bash
./kvm test-clean install check recheck diff
```

And select specific tests with wildcards:

```bash
./kvm install check diff testing/pluto/*ikev2*
```

_(Note: Older methods like `make kvm-test` or `kvmrunner.py` are deprecated in favor of the `./kvm` top-level script)._
