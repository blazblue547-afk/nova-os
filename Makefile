# Nova OS Build System — from source
# Produces a bootable image for Raspberry Pi 5

NOVA_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))
BUILD_DIR  := $(NOVA_ROOT)build
ROOTFS     := $(NOVA_ROOT)rootfs-custom
BOOT       := $(NOVA_ROOT)boot
IMAGE      := $(NOVA_ROOT)nova-os-3.0-from-source.img

KERNEL_DIR   := $(BUILD_DIR)/linux-7.0.12
SYSTEMD_DIR  := $(BUILD_DIR)/systemd-260.2
BUSYBOX_DIR  := $(BUILD_DIR)/busybox-1.36.1
ARCH         := arm64
CROSS        := aarch64-linux-gnu-

.PHONY: all kernel systemd busybox rootfs image clean

all: kernel systemd busybox image
	@echo "✦ Nova OS build complete: $(IMAGE)"
	@echo "Flash: sudo dd if=$(IMAGE) of=/dev/mmcblk0 bs=4M status=progress"

kernel:
	cd $(KERNEL_DIR) && \
		ARCH=$(ARCH) CROSS_COMPILE=$(CROSS) make -j4 Image modules dtbs

systemd:
	cd $(SYSTEMD_DIR) && \
		meson setup build \
			--prefix=/usr \
			--buildtype=release \
			-Dmode=release \
			-Dpam=false \
			-Dselinux=false \
			-Dapparmor=false \
			-Dpolkit=false \
			-Dtests=false \
			-Dman=false \
			-Dhtml=false \
			-Dnetworkd=true \
			-Dresolve=true \
			-Dlogind=true \
			-Dcoredump=false \
			-Dhostnamed=false \
			-Dtimedated=false \
			-Dlocaled=false \
			-Dvconsole=false \
			-Dquotacheck=false \
			-Dbacklight=false \
			-Drfkill=false \
			-Dxdg-autostart=false \
			-Dldconfig=false \
			-Dhibernate=false && \
		ninja -C build -j4 && \
		DESTDIR=$(ROOTFS) ninja -C build install

busybox:
	cd $(BUSYBOX_DIR) && \
		make -j4 && \
		make CONFIG_PREFIX=$(ROOTFS) install

image:
	bash $(NOVA_ROOT)mkimage.sh

clean:
	rm -f $(IMAGE)
	cd $(KERNEL_DIR) && make clean
	cd $(SYSTEMD_DIR) && rm -rf build
	cd $(BUSYBOX_DIR) && make clean
