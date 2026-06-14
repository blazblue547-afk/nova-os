# ✦ Nova OS

**Burn bright, run light.**

A minimalist Linux distribution built from the latest mainline kernel and busybox userspace. Designed for the Raspberry Pi 5, Nova OS strips away everything unnecessary — no systemd, no package manager, no bloat. Just the kernel, a shell, and you.

```
  ╔══════════════════════════════════════╗
  ║          N O V A   O S              ║
  ║       kernel 7.0.12-nova-os         ║
  ║   "Burn bright, run light."         ║
  ╚══════════════════════════════════════╝
```

## Specifications

| Component    | Version            |
|-------------|--------------------|
| Kernel       | Linux 7.0.12-nova-os |
| Userspace    | BusyBox 1.36.1      |
| Shell        | ash (busybox)       |
| Init         | Custom (busybox init)|
| Architecture | aarch64 (ARM64)     |
| Target       | Raspberry Pi 5      |
| Image size   | ~1 GB               |

## Build from Source

```bash
make all          # Build kernel + busybox + rootfs + image
make kernel       # Build only the kernel
make busybox      # Build only busybox
make image        # Package into bootable .img
```

## Flash to SD Card

```bash
sudo dd if=nova-os-1.0-starlight.img of=/dev/mmcblk0 bs=4M status=progress
```

## Directory Layout

```
nova-os/
├── Makefile           # Build system
├── boot/              # Boot partition files
│   ├── config.txt     # Pi bootloader config
│   └── cmdline.txt    # Kernel command line
├── rootfs/            # Root filesystem
│   ├── init           # Init script
│   └── etc/           # Config files
│       ├── issue      # Pre-login banner
│       ├── motd       # Post-login banner
│       ├── hostname   # "nova-os"
│       ├── os-release # OS identity
│       ├── fstab      # Mount table
│       ├── inittab    # Init table
│       └── profile    # Shell config
└── build/             # Build artifacts
    ├── linux-7.0.12/
    └── busybox-1.36.1/
```

## License

Nova OS inherits the GPLv2 license from the Linux kernel.
