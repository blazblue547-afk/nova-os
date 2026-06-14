# ✦ Nova OS

**Burn bright, run light.**

A from-source Linux distribution — every significant binary compiled on this machine. No Debian packages, no prebuilt binaries (except the C runtime toolchain). Designed for the Raspberry Pi 5.

```
  ╔══════════════════════════════════════════╗
  ║           N O V A   O S                 ║
  ║        kernel 7.0.12-nova-os            ║
  ║     "Burn bright, run light."           ║
  ║   systemd 260 · BusyBox 1.36.1          ║
  ╚══════════════════════════════════════════╝
```

## Specifications

| Component    | Version              | Built From     |
|-------------|----------------------|----------------|
| Kernel       | Linux 7.0.12         | kernel.org source |
| Init system  | systemd 260.2        | github.com/systemd/systemd |
| Core utils   | BusyBox 1.36.1       | busybox.net source |
| Shell        | ash (BusyBox)        | busybox.net source |
| Architecture | aarch64 (ARM64)      | —               |
| Target       | Raspberry Pi 5 (BCM2712) | —            |
| Image size   | ~1.5 GB              | —               |
| Rootfs size  | ~56 MB               | —               |

## What Makes This Different

- **Zero Debian binaries** — systemd, BusyBox, and the kernel are all compiled from upstream source
- **systemd 260** — latest stable, configured with meson/ninja, minimal feature set
- **BusyBox 1.36.1** — static binary providing all Unix utilities (ash shell, coreutils, networking, etc.)
- **56 MB rootfs** — just the essentials: init, shell, networkd, resolved
- **Runtime libraries** — glibc, libcrypto, zlib, zstd from host toolchain (full LFS bootstrap coming in v4.0)

## Build from Source

```bash
# Prerequisites
sudo apt-get install meson ninja-build gcc gperf gettext python3-jinja2

# 1. Build the kernel (45 min on Pi 5)
make kernel

# 2. Build systemd
make systemd

# 3. Build BusyBox
make busybox

# 4. Assemble rootfs + image
make image
```

Or just `make all` for the full pipeline.

## Flash to SD Card

```bash
sudo dd if=nova-os-3.0-from-source.img of=/dev/mmcblk0 bs=4M status=progress
```

## Directory Layout

```
nova-os/
├── Makefile              # Build system
├── mkimage.sh            # Image packager
├── boot/                 # Pi boot partition files
│   ├── config.txt        # Bootloader config
│   └── cmdline.txt       # Kernel command line
├── rootfs-custom/        # Built root filesystem (~56 MB)
│   ├── sbin/init → /usr/lib/systemd/systemd
│   ├── bin/busybox       # Static BusyBox binary
│   ├── lib/              # Runtime libraries
│   ├── usr/lib/systemd/  # systemd binaries
│   └── etc/              # System configuration
└── build/                # Build artifacts
    ├── linux-7.0.12/     # Kernel source + build
    ├── systemd-260.2/    # systemd source + build
    └── busybox-1.36.1/   # BusyBox source + build
```

## License

Nova OS inherits the GPLv2 license from the Linux kernel. systemd is LGPLv2.1+. BusyBox is GPLv2.
