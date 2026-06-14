# ✦ Nova OS

**Burn bright, run light.**

A 100% from-source Linux distribution. Every binary on this image was compiled on this machine — kernel, systemd, glibc, BusyBox, openssl, OpenSSH, zlib, zstd, libcap, libxcrypt. Zero prebuilt packages. Designed for the Raspberry Pi 5.

```
  ╔══════════════════════════════════════════╗
  ║           N O V A   O S                 ║
  ║        kernel 7.0.12-nova-os            ║
  ║     "Burn bright, run light."           ║
  ║   100% from source — zero prebuilt      ║
  ║   systemd 260 · OpenSSH 10.3            ║
  ╚══════════════════════════════════════════╝
```

## Specifications

| Component    | Version              | Built From                  |
|-------------|----------------------|-----------------------------|
| Kernel       | Linux 7.0.12         | kernel.org                  |
| C Library    | glibc 2.41           | ftp.gnu.org                 |
| Init system  | systemd 260.2        | github.com/systemd/systemd  |
| Core utils   | BusyBox 1.36.1       | busybox.net (static)        |
| SSH server   | OpenSSH 10.3p1       | openssh.com                 |
| SSL/TLS      | OpenSSL 3.5.6        | openssl.org                 |
| Compression  | zlib 1.3.1 + zstd 1.5.7 | github.com               |
| Capabilities | libcap 2.75          | kernel.org                  |
| Crypt        | libxcrypt 4.4.38     | github.com/besser82         |
| Architecture | aarch64 (ARM64)      | —                           |
| Target       | Raspberry Pi 5 (BCM2712) | —                        |
| Image size   | ~1.5 GB              | —                           |

## Quick Start

```bash
# Flash to SD card
sudo dd if=nova-os-4.2-firstboot.img of=/dev/mmcblk0 bs=4M status=progress

# Boot your Pi 5 — first-boot setup runs automatically:
# • Root partition expands to fill your SD card
# • Fresh SSH host keys are generated
# • Root password is expired (must change on first login)

# After first boot completes (it reboots once):
ssh root@<pi-ip>
# You'll be forced to change the password from 'nova'
```

## Services at Boot

| Service | Status | Description |
|---------|--------|-------------|
| systemd-networkd | enabled | DHCP networking |
| systemd-resolved | enabled | DNS resolution |
| sshd | enabled | OpenSSH server, port 22 |
| nova-firstboot | enabled | First-boot setup (runs once) |
| nova-splash | enabled | Boot banner on tty1 |

## Build from Source

```bash
sudo apt-get install meson ninja-build gcc gawk gperf gettext python3-jinja2

make all   # kernel + toolchain + systemd + openssh + busybox + e2fsprogs + image
```

Individual targets: `make kernel`, `make toolchain`, `make systemd`, `make openssh`, `make busybox`, `make image`.

## Version History

| Version | Key Changes |
|---------|-------------|
| v1.0 | BusyBox init, minimal |
| v2.0 | systemd via Debian minbase |
| v3.0 | systemd + BusyBox from source |
| v4.0 | Full bootstrap: glibc + all libs from source |
| **v4.1** | **OpenSSH 10.3 from source, auto-starts at boot** |
| **v4.2** | **First-boot auto-expand, fresh SSH keys, forced password change** |

## License

glibc: LGPLv2.1+ · systemd: LGPLv2.1+ · Linux: GPLv2 · BusyBox: GPLv2 · OpenSSH: BSD · OpenSSL: Apache 2.0
