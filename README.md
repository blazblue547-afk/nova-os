# ✦ Nova OS

**Burn bright, run light.**

A lightweight Linux distribution built from the latest mainline kernel and a minimal Debian userspace. Designed for the Raspberry Pi 5, Nova OS pairs a custom-compiled kernel with systemd for modern init and service management — keeping things small but capable.

```
  ╔══════════════════════════════════════════╗
  ║           N O V A   O S                 ║
  ║        kernel 7.0.12-nova-os            ║
  ║     "Burn bright, run light."           ║
  ╚══════════════════════════════════════════╝
```

## Specifications

| Component    | Version              |
|-------------|----------------------|
| Kernel       | Linux 7.0.12-nova-os  |
| Userspace    | Debian Bookworm (minbase) |
| Init         | systemd 252           |
| Shell        | bash                  |
| Architecture | aarch64 (ARM64)       |
| Target       | Raspberry Pi 5 (BCM2712) |
| Image size   | ~1.5 GB               |

## v2.0 — What Changed

- **systemd replaces BusyBox init** — proper service management, cgroups, socket activation
- **Debian minbase userspace** — apt-ready, 344MB rootfs
- **systemd-networkd** — DHCP networking out of the box
- **systemd-resolved** — DNS resolution
- **Nova splash service** — boot banner on tty1
- **Root password:** `nova` (change on first login)

## Build from Source

```bash
make kernel       # Build the kernel (45 min on Pi 5)
make image        # Package into bootable .img (requires sudo)
make all          # Kernel + image
```

The rootfs is pre-built via debootstrap. To rebuild it:

```bash
sudo apt-get install debootstrap
sudo debootstrap --arch=arm64 --variant=minbase \
  --include=systemd,systemd-sysv,udev,dbus,apt,kmod,netbase \
  bookworm rootfs http://deb.debian.org/debian
# Then customize: hostname, os-release, splash service, networking
```

## Flash to SD Card

```bash
sudo dd if=nova-os-2.0-systemd.img of=/dev/mmcblk0 bs=4M status=progress
```

## Directory Layout

```
nova-os/
├── Makefile           # Build system
├── boot/              # Boot partition files
│   ├── config.txt     # Pi bootloader config
│   └── cmdline.txt    # Kernel command line
├── rootfs/            # Debian minbase + systemd rootfs
│   ├── bin/           # Essential binaries
│   ├── sbin/          # System binaries
│   │   └── init → /lib/systemd/systemd
│   ├── etc/
│   │   ├── systemd/   # systemd config + services
│   │   ├── hostname   # "nova-os"
│   │   ├── os-release # OS identity
│   │   ├── motd       # Login banner
│   │   └── fstab      # Mount table
│   └── lib/systemd/   # systemd itself
└── build/             # Build artifacts
    └── linux-7.0.12/  # Kernel source + build
```

## License

Nova OS inherits the GPLv2 license from the Linux kernel.
