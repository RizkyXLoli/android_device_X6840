#
# Copyright (C) 2026 The TWRP X6840 Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Restores recovery-ramdisk content that the TWRP 16.0 Soong migration
# (commits ba432fa3 / 224d53c9 / f5039fe0 in bootable/recovery) stopped
# installing, so our vendor_boot ramdisk matches the TWRP-16.0-v1 release:
#
#   terminfo DB      -> /system/etc/terminfo        (2871 entries; was: only b/)
#   /sbin/sh         -> symlink /system/bin/sh      (TWRP terminal + relink target)
#   /sbin/bash       -> symlink /system/bin/bash
#   lpdumpd.rc       -> /system/etc/init/lpdumpd.rc (lpdumpd.recovery ships no init_rc)
#   mke2fs.conf      -> /system/etc/mke2fs.conf     (recovery variant not required)
#   health@2.1 frag  -> /vendor/etc/vintf/manifest/ (recovery variant has no vintf_fragments)
#   task_profiles_30 -> /system/etc/task_profiles/  (legacy versioned copy the old
#                       Android.mk made; init reads task_profiles.json otherwise)
#
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := twrp_ramdisk_extras
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_RECOVERY_ROOT_OUT)

LOCAL_POST_INSTALL_CMD += \
    echo "--- twrp_ramdisk_extras: restoring recovery ramdisk files ---"; \
    cp -rf external/libncurses/lib/terminfo $(TARGET_RECOVERY_ROOT_OUT)/system/etc/; \
    mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/sbin; \
    ln -sf /system/bin/sh $(TARGET_RECOVERY_ROOT_OUT)/sbin/sh; \
    ln -sf /system/bin/bash $(TARGET_RECOVERY_ROOT_OUT)/sbin/bash; \
    mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/system/etc/init; \
    cp -f system/extras/partition_tools/lpdumpd.rc \
        $(TARGET_RECOVERY_ROOT_OUT)/system/etc/init/lpdumpd.rc; \
    cp -f system/extras/ext4_utils/mke2fs.conf \
        $(TARGET_RECOVERY_ROOT_OUT)/system/etc/mke2fs.conf; \
    mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/vendor/etc/vintf/manifest; \
    cp -f hardware/interfaces/health/2.1/default/android.hardware.health@2.1.xml \
        $(TARGET_RECOVERY_ROOT_OUT)/vendor/etc/vintf/manifest/android.hardware.health@2.1.xml; \
    mkdir -p $(TARGET_RECOVERY_ROOT_OUT)/system/etc/task_profiles; \
    cp -f system/core/libprocessgroup/profiles/task_profiles.json \
        $(TARGET_RECOVERY_ROOT_OUT)/system/etc/task_profiles/task_profiles_30.json; \
    echo "--- twrp_ramdisk_extras: terminfo entries: $$(find $(TARGET_RECOVERY_ROOT_OUT)/system/etc/terminfo -type f | wc -l) ---"

include $(BUILD_PHONY_PACKAGE)
