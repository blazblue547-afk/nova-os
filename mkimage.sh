#!/bin/bash
# Nova OS — package bootable image
# Run after kernel compilation completes

set -e

NOVA_ROOT="/home/joe/nova-os"
IMAGE="$NOVA_ROOT/nova-os-2.0-systemd.img"
SIZE_MB=1536  # 1.5 GB
TMP_MNT="/tmp/nova-os-mnt"

echo "==> Nova OS Image Builder"
echo ""

# Check kernel exists
KERNEL_IMAGE="$NOVA_ROOT/build/linux-7.0.12/arch/arm64/boot/Image"
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "ERROR: Kernel Image not found at $KERNEL_IMAGE"
    echo "Build the kernel first: make kernel"
    exit 1
fi
echo "✓ Kernel Image: $(ls -lh $KERNEL_IMAGE | awk '{print $5}')"

# Find DTB
DTB=$(ls $NOVA_ROOT/build/linux-7.0.12/arch/arm64/boot/dts/broadcom/bcm2712-rpi-5-b.dtb 2>/dev/null)
if [ -z "$DTB" ]; then
    # Fallback
    DTB=$(ls $NOVA_ROOT/build/linux-7.0.12/arch/arm64/boot/dts/broadcom/bcm2712*.dtb 2>/dev/null | head -1)
fi
if [ -z "$DTB" ]; then
    echo "WARNING: No Pi 5 DTB found, image may not boot"
else
    echo "✓ Device Tree: $(basename $DTB)"
fi

# Create image
echo ""
echo "==> Creating ${SIZE_MB}MB image..."
dd if=/dev/zero of="$IMAGE" bs=1M count=$SIZE_MB status=progress 2>/dev/null
echo "✓ Image file created: $(ls -lh $IMAGE | awk '{print $5}')"

# Partition
echo "==> Partitioning..."
sudo parted -s "$IMAGE" mklabel msdos
sudo parted -s "$IMAGE" mkpart primary fat32 1MiB 256MiB
sudo parted -s "$IMAGE" mkpart primary ext4 256MiB 100%
sudo parted -s "$IMAGE" set 1 boot on
echo "✓ Partitions created"

# Map loop device
LOOP=$(sudo losetup -fP --show "$IMAGE")
echo "✓ Loop device: $LOOP"

# Format partitions
echo "==> Formatting..."
sudo mkfs.vfat -F 32 -n NOVA-BOOT "${LOOP}p1" > /dev/null 2>&1
sudo mkfs.ext4 -F -L NOVA-ROOT "${LOOP}p2" > /dev/null 2>&1
echo "✓ Filesystems created"

# Mount
mkdir -p "$TMP_MNT/boot" "$TMP_MNT/root"
sudo mount "${LOOP}p1" "$TMP_MNT/boot"
sudo mount "${LOOP}p2" "$TMP_MNT/root"

# Copy boot files
echo "==> Copying boot files..."
sudo cp "$KERNEL_IMAGE" "$TMP_MNT/boot/Image"
if [ -n "$DTB" ]; then
    sudo cp "$DTB" "$TMP_MNT/boot/"
fi
sudo cp "$NOVA_ROOT/boot/config.txt" "$TMP_MNT/boot/"
sudo cp "$NOVA_ROOT/boot/cmdline.txt" "$TMP_MNT/boot/"
echo "✓ Boot partition ready"

# Copy rootfs
echo "==> Copying root filesystem..."
sudo cp -a "$NOVA_ROOT/rootfs/"* "$TMP_MNT/root/"
echo "✓ Root filesystem ready (systemd $(sudo chroot "$TMP_MNT/root" systemd --version 2>/dev/null | head -1 | awk '{print $2}'))"

# Unmount
echo "==> Unmounting..."
sudo umount "$TMP_MNT/boot"
sudo umount "$TMP_MNT/root"
sudo losetup -d "$LOOP"
rm -rf "$TMP_MNT"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Nova OS image built successfully  ║"
echo "║   $(ls -lh $IMAGE | awk '{print $5}')                        ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Flash to SD card:"
echo "  sudo dd if=$IMAGE of=/dev/mmcblkX bs=4M status=progress"
echo ""
