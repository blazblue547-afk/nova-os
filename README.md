# ✦ Nova OS

**Burn bright, run light.**

A 100% from-source Linux distribution. Every binary on this image was compiled on this machine — kernel, systemd, glibc, BusyBox, openssl, zlib, zstd, libcap, libxcrypt. Zero prebuilt packages. Designed for the Raspberry Pi 5.

```
  ╔══════════════════════════════════════════╗
  ║           N O V A   O S                 ║
  ║        kernel 7.0.12-nova-os            ║
  ║     "Burn bright, run light."           ║
  ║   100% from source — zero prebuilt      ║
  ║   systemd 260 · glibc 2.41 · BusyBox    ║
  ╚══════════════════════════════════════════╝
```

## Specifications

| Component    | Version              | Built From                  |
|-------------|----------------------|-----------------------------|
| Kernel       | Linux 7.0.12         | kernel.org                  |
| C Library    | glibc 2.41           | ftp.gnu.org                 |
| Init system  | systemd 260.2        | github.com/systemd/systemd  |
| Core utils   | BusyBox 1.36.1       | busybox.net (static)        |
| SSL/TLS      | OpenSSL 3.5.6        | openssl.org                 |
| Compression  | zlib 1.3.1 + zstd 1.5.7 | github.com               |
| Capabilities | libcap 2.75          | kernel.org                  |
| Crypt        | libxcrypt 4.4.38     | github.com/besser82         |
| Architecture | aarch64 (ARM64)      | —                           |
| Target       | Raspberry Pi 5 (BCM2712) | —                        |
| Image size   | ~1.5 GB              | —                           |
| Rootfs size  | ~222 MB              | —                           |

## Version History

| Version | Init     | Userspace      | Source Purity |
|---------|----------|----------------|---------------|
| v1.0    | BusyBox  | BusyBox static | Full from-source |
| v2.0    | systemd  | Debian minbase | Debian binaries |
| v3.0    | systemd  | BusyBox + host libs | Kernel+systemd+busybox from source |
| **v4.0** | systemd | **Full bootstrap** | **100% from source — incl. glibc** |

## Build from Source

```bash
# Prerequisites
sudo apt-get install meson ninja-build gcc gawk gperf gettext python3-jinja2

# Full build (kernel + toolchain + systemd + busybox + image)
make all
```

Individual targets: `make kernel`, `make toolchain`, `make systemd`, `make busybox`, `make image`.

## Flash to SD Card

```bash
sudo dd if=nova-os-4.0-bootstrap.img of=/dev/mmcblk0 bs=4M status=progress
```

## What's Inside

Every library and binary compiled from upstream source on this Raspberry Pi 5:

- **glibc 2.41** — C runtime, math lib, dynamic linker, NSS, pthreads
- **systemd 260.2** — init, journald, networkd, resolved, logind, udevd
- **BusyBox 1.36.1** — ash shell, 200+ Unix utilities (static binary)
- **OpenSSL 3.5.6** — libcrypto + libssl (shared)
- **zlib 1.3.1** — compression
- **zstd 1.5.7** — modern compression
- **libcap 2.75** — POSIX capabilities
- **libxcrypt 4.4.38** — password hashing

## Directory Layout

```
nova-os/
├── Makefile              # Build system
├── mkimage.sh            # Image packager
├── boot/                 # Pi boot partition
├── rootfs-custom/        # Built root filesystem
│   ├── sbin/init → /usr/lib/systemd/systemd
│   ├── bin/busybox       # Static, from source
│   ├── lib/              # OUR glibc + all runtime libs
│   ├── usr/lib/systemd/  # OUR systemd binaries
│   └── etc/              # System configuration
└── build/                # All sources + build artifacts
    ├── linux-7.0.12/     # Kernel
    ├── systemd-260.2/    # systemd
    ├── busybox-1.36.1/   # BusyBox
    └── toolchain/        # glibc, openssl, zlib, zstd, libcap, libxcrypt
```

## License

glibc: LGPLv2.1+ · systemd: LGPLv2.1+ · Linux: GPLv2 · BusyBox: GPLv2 · OpenSSL: Apache 2.0
