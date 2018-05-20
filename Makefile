# The directory to be the top of the tree
TOP ?=

ifeq ($(TOP),)
	ABS_TOP := $(abspath $(shell pwd))/
else
	ABS_TOP := $(abspath $(TOP))/
endif

VENDOR_DIR := $(ABS_TOP)vendor/
OUT_DIR    := $(ABS_TOP)out/

SYSTEM_HOSTNAME       ?= rospi
IMAGE_SIZE_ADJUSTMENT ?= +2G

SOURCE_SYSTEM_IMAGE_DOWNLOAD_URL ?= https://www.finnie.org/software/raspberrypi/ubuntu-rpi3/2018-04-21/ubuntu-16.04-preinstalled-server-armhf+raspi3.img.xz
SOURCE_SYSTEM_IMAGE_FILENAME     := ubuntu-16.04-preinstalled-server-armhf+raspi3.img.xz
SOURCE_SYSTEM_IMAGE_PATH         := $(VENDOR_DIR)system-image/$(SOURCE_SYSTEM_IMAGE_FILENAME)
SOURCE_SYSTEM_IMAGE_SHA          := 910ebc007e58605b848f418962f21a2663f9501fc3157a5eec0405e9bfd8fead

TEMPORARY_BUILD_DIR         ?= /tmp/rospi-system-image-build
TEMPORARY_SYSTEM_IMAGE_PATH := $(TEMPORARY_BUILD_DIR)/ubuntu-16.04-server-armhf+rospi3.img
TEMPORARY_ROOTFS_DIR        := $(TEMPORARY_BUILD_DIR)/rootfs
TEMPORARY_BOOT_DIR          := $(TEMPORARY_BUILD_DIR)/boot

BUILT_SYSTEM_IMAGE_PATH := $(OUT_DIR)system-image/ubuntu-16.04-server-armhf+rospi3.img

ROOTFS_SOURCE  := $(shell find "$(ABS_TOP)system-image" -name "*")
SCRIPTS_SOURCE := $(shell find "$(ABS_TOP)scripts" -name "*")
CUSTOM_SOURCE  := $(shell find "$(ABS_TOP)custom" -name "*")
ALL_SOURCES    := $(ROOTFS_SOURCE) $(SCRIPTS_SOURCE) $(CUSTOM_SOURCE)

.PHONY: rospi3 system-image-pre-build-check

rospi3: $(BUILT_SYSTEM_IMAGE_PATH)

system-image-pre-build-check:
	scripts/01-system-image-pre-build-check.sh

$(SOURCE_SYSTEM_IMAGE_PATH):
	mkdir -p $(dir $@)
	# If it fails here, may need to get an old image or recertify the newest
	# available one.
	cd $(dir $@) && wget $(SOURCE_SYSTEM_IMAGE_DOWNLOAD_URL)
	cd $(dir $@) && sha256sum $(SOURCE_SYSTEM_IMAGE_FILENAME) | grep $(SOURCE_SYSTEM_IMAGE_SHA)

$(BUILT_SYSTEM_IMAGE_PATH): $(SOURCE_SYSTEM_IMAGE_PATH) $(ALL_SOURCES) system-image-pre-build-check
	rm -rf $(TEMPORARY_BUILD_DIR)
	mkdir -p $(dir $@)
	mkdir -p $(TEMPORARY_ROOTFS_DIR)
	mkdir -p $(TEMPORARY_BOOT_DIR)
	cd $(dir $(SOURCE_SYSTEM_IMAGE_PATH)) && xzcat $(SOURCE_SYSTEM_IMAGE_FILENAME) > $(TEMPORARY_SYSTEM_IMAGE_PATH)
	scripts/02-setup-system-image.sh $(TEMPORARY_SYSTEM_IMAGE_PATH) $(SYSTEM_HOSTNAME) $(IMAGE_SIZE_ADJUSTMENT)
	cp $(TEMPORARY_SYSTEM_IMAGE_PATH) $@
	sha256sum $@ > $@.sha256sum
