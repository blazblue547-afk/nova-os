# Nova OS Build System
# Produces a bootable image for Raspberry Pi 5

NOVA_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))
BUILD_DIR := $(NOVA_ROOT)build
ROOTFS := $(NOVA_ROOT)rootfs
BOOT := $(NOVA_ROOT)boot
IMAGE := $(NOVA_ROOT)nova-os-1.0-starlight.img
SIZE_MB := 1024

KERNEL_DIR := $(BUILD_DIR)/linux-7.0.12
BUSYBOX_DIR := $(BUILD_DIR)/busybox-1.36.1
ARCH := arm64
CROSS := aarch64-linux-gnu-

.PHONY: all kernel busybox rootfs image clean

all: kernel busybox rootfs image
	@echo "Nova OS build complete: $(IMAGE)"

kernel:
	cd $(KERNEL_DIR) && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make defconfig && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) scripts/kconfig/merge_config.sh .config novaos_fragment.config && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make olddefconfig && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make -j4 Image modules dtbs

busybox:
	cd $(BUSYBOX_DIR) && \
		make defconfig && \
		sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config && \
		make -j4 && \
		make CONFIG_PREFIX=$(ROOTFS) install

rootfs:
	cp $(NOVA_ROOT)init $(ROOTFS)/init
	chmod +x $(ROOTFS)/init
	chmod +x $(ROOTFS)/etc/init.d/rcS
	mkdir -p $(ROOTFS)/proc $(ROOTFS)/sys $(ROOTFS)/dev $(ROOTFS)/tmp $(ROOTFS)/run

image:
	dd if=/dev/zero of=$(IMAGE) bs=1M count=$(SIZE_MB)
	parted -s $(IMAGE) mklabel msdos
	parted -s $(IMAGE) mkpart primary fat32 1MiB 257MiB
	parted -s $(IMAGE) mkpart primary ext4 257MiB 100%
	@echo "Image created. Flash to SD: dd if=$(IMAGE) of=/dev/mmcblkX bs=4M"

clean:
	rm -f $(IMAGE)
	cd $(KERNEL_DIR) && make clean
	cd $(BUSYBOX_DIR) && make clean
