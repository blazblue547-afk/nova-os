# Nova OS — QEMU

Boot Nova OS under QEMU emulation (ARM64 virt machine).

## Quick Start

```bash
# Install QEMU
sudo apt install qemu-system-arm

# Add yourself to kvm group (for hardware acceleration)
sudo usermod -a -G kvm $USER
# Log out and back in for this to take effect

# Run
./run.sh
```

## What You Get

- ARM64 virtual machine with 4 Cortex-A76 cores, 2GB RAM
- VirtIO block storage (raw image)
- VirtIO networking with port forward: `localhost:2222` → guest SSH port 22
- Serial console in your terminal

## SSH Access

Once booted:
```bash
ssh -p 2222 root@localhost
```
Password: `nova` (forced change on first login)

## Configuration

Override defaults via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `NOVA_IMAGE` | `../nova-os-4.3.1.img` | Path to raw disk image |
| `NOVA_CPU` | `cortex-a76` | CPU model |
| `NOVA_SMP` | `4` | Number of CPU cores |
| `NOVA_MEM` | `2048` | RAM in MB |
| `NOVA_SSH_PORT` | `2222` | Host port for SSH forwarding |

## Acceleration

- **KVM** (near-native): auto-detected if `/dev/kvm` is writable
- **TCG** (emulation): fallback — works but ~50-90x slower

## Quit

Press `Ctrl-A` then `X` to exit QEMU.
