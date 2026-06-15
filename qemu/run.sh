#!/usr/bin/env bash
# Nova OS — QEMU Launcher (ARM64 virt)
# Boots the Nova OS raw image under QEMU emulation.
#
# Usage:
#   ./run.sh [image_path]
#
# Default image: ../nova-os-4.3.1.img (or set NOVA_IMAGE env var)
#
# After boot:
#   ssh -p 2222 root@localhost    (password: nova, forced change)
#
# Requirements:
#   qemu-system-aarch64 (Debian: apt install qemu-system-arm)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/../build"

# ── Configuration ──────────────────────────────────────────────
IMAGE="${NOVA_IMAGE:-${SCRIPT_DIR}/../nova-os-4.3.1.img}"

# Prefer local kernel, fall back to build tree
if [ -f "${SCRIPT_DIR}/Image" ]; then
    KERNEL="${SCRIPT_DIR}/Image"
elif [ -f "${BUILD_DIR}/linux-7.0.12/arch/arm64/boot/Image" ]; then
    KERNEL="${BUILD_DIR}/linux-7.0.12/arch/arm64/boot/Image"
else
    echo "ERROR: kernel Image not found" >&2
    exit 1
fi

CPU="${NOVA_CPU:-cortex-a76}"
SMP="${NOVA_SMP:-4}"
MEM="${NOVA_MEM:-2048}"
SSH_PORT="${NOVA_SSH_PORT:-2222}"

# ── Validate ───────────────────────────────────────────────────
for f in "$IMAGE" "$KERNEL"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: not found — $f" >&2
        exit 1
    fi
done

# ── Acceleration ──────────────────────────────────────────────
if [ -w /dev/kvm ]; then
    ACCEL="kvm"
    echo "   Accel:    KVM (hardware)"
else
    ACCEL="tcg"
    echo "   Accel:    TCG (emulation — slow)"
fi
echo "═══════════════════════════════════════════"
echo "  Nova OS — QEMU (ARM64 virt)"
echo "  CPU:      $CPU"
echo "  Cores:    $SMP"
echo "  RAM:      ${MEM}MB"
echo "  Accel:    ${ACCEL}"
echo "  SSH:      localhost:$SSH_PORT → guest:22"
echo "  Console:  this terminal (Ctrl-A X to quit)"
echo "═══════════════════════════════════════════"
echo ""

exec qemu-system-aarch64 \
    -M virt,accel=${ACCEL} \
    -cpu "$CPU" \
    -smp "$SMP" \
    -m "$MEM" \
    \
    -kernel "$KERNEL" \
    -append "console=ttyAMA0 root=/dev/vda2 rootwait rw quiet loglevel=3" \
    \
    -drive file="$IMAGE",format=raw,if=virtio \
    \
    -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
    -device virtio-net-device,netdev=net0 \
    \
    -nographic
