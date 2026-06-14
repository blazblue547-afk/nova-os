# Nova OS Build System
# Produces a bootable image for Raspberry Pi 5

NOVA_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))
BUILD_DIR  := $(NOVA_ROOT)build
ROOTFS     := $(NOVA_ROOT)rootfs
BOOT       := $(NOVA_ROOT)boot
IMAGE      := $(NOVA_ROOT)nova-os-2.0-systemd.img

KERNEL_DIR := $(BUILD_DIR)/linux-7.0.12
ARCH       := arm64
CROSS      := aarch64-linux-gnu-

.PHONY: all kernel rootfs image clean

all: kernel image
	@echo "✦ Nova OS build complete: $(IMAGE)"
	@echo "Flash: sudo dd if=$(IMAGE) of=/dev/mmcblk0 bs=4M status=progress"

kernel:
	cd $(KERNEL_DIR) && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make defconfig && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) scripts/kconfig/merge_config.sh .config novaos_fragment.config && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make olddefconfig && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make -j4 Image modules dtbs

rootfs:
	@echo "Rootfs is built via debootstrap. See README.md for instructions."
	@echo "Pre-built rootfs at $(ROOTFS)/"

image:
	bash $(NOVA_ROOT)mkimage.sh

clean:
	rm -f $(IMAGE)
	cd $(KERNEL_DIR) && make clean
