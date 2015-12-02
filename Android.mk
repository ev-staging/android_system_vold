LOCAL_PATH:= $(call my-dir)

common_src_files := \
	VolumeManager.cpp \
	CommandListener.cpp \
	CryptCommandListener.cpp \
	VoldCommand.cpp \
	NetlinkManager.cpp \
	NetlinkHandler.cpp \
	Process.cpp \
	fs/Exfat.cpp \
	fs/Ext4.cpp \
	fs/F2fs.cpp \
	fs/Ntfs.cpp \
	fs/Vfat.cpp \
	Loop.cpp \
	Devmapper.cpp \
	ResponseCode.cpp \
	CheckBattery.cpp \
	Ext4Crypt.cpp \
	VoldUtil.c \
	cryptfs.cpp \
	Disk.cpp \
	DiskPartition.cpp \
	VolumeBase.cpp \
	PublicVolume.cpp \
	PrivateVolume.cpp \
	EmulatedVolume.cpp \
	Utils.cpp \
	MoveTask.cpp \
	Benchmark.cpp \
	TrimTask.cpp \
	Keymaster.cpp \
	KeyStorage.cpp \
	ScryptParameters.cpp \
	secontext.cpp \

common_c_includes := \
	system/extras/f2fs_utils \
	external/scrypt/lib/crypto \
	frameworks/native/include \
	system/security/keystore \

common_shared_libraries := \
	libsysutils \
	libbinder \
	libcutils \
	liblog \
	libdiskconfig \
	libhardware_legacy \
	liblogwrap \
	libext4_utils \
	libf2fs_sparseblock \
	libcrypto_utils \
	libcrypto \
	libselinux \
	libutils \
	libhardware \
	libbase \
	libhwbinder \
	libhidlbase \
	android.hardware.keymaster@3.0 \
	libkeystore_binder

common_static_libraries := \
	libbootloader_message \
	libfs_mgr \
	libfec \
	libfec_rs \
	libsquashfs_utils \
	libscrypt_static \
	libbatteryservice \
	libavb \

vold_conlyflags := -std=c11
vold_cflags := -Werror -Wall -Wno-missing-field-initializers -Wno-unused-variable -Wno-unused-parameter

required_modules :=
ifeq ($(TARGET_USERIMAGES_USE_EXT4), true)
  ifeq ($(TARGET_USES_MKE2FS), true)
    vold_cflags += -DTARGET_USES_MKE2FS
    required_modules += mke2fs
  else
    required_modules += make_ext4fs
  endif
endif

ifeq ($(BOARD_REQUIRES_FORCE_VPARTITION),true)
vold_cflags += -DCONFIG_FORCE_VPARTITION
endif

ifeq ($(TARGET_HW_DISK_ENCRYPTION),true)
  TARGET_CRYPTFS_HW_PATH ?= vendor/qcom/opensource/cryptfs_hw
  common_c_includes += $(TARGET_CRYPTFS_HW_PATH)
  common_shared_libraries += libcryptfs_hw
  vold_cflags += -DCONFIG_HW_DISK_ENCRYPTION
endif

ifeq ($(TARGET_KERNEL_HAVE_EXFAT),true)
  vold_cflags += -DCONFIG_KERNEL_HAVE_EXFAT
endif

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE := libvold
LOCAL_CLANG := true
LOCAL_SRC_FILES := $(common_src_files)
LOCAL_C_INCLUDES := $(common_c_includes)
LOCAL_SHARED_LIBRARIES := $(common_shared_libraries)
LOCAL_STATIC_LIBRARIES := $(common_static_libraries)
LOCAL_MODULE_TAGS := eng tests
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)
LOCAL_REQUIRED_MODULES := $(required_modules)

include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_MODULE := vold
LOCAL_CLANG := true
LOCAL_SRC_FILES := \
	main.cpp \
	$(common_src_files)

LOCAL_INIT_RC := vold.rc

LOCAL_C_INCLUDES := $(common_c_includes)
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)

LOCAL_SHARED_LIBRARIES := $(common_shared_libraries)
LOCAL_STATIC_LIBRARIES := $(common_static_libraries)
LOCAL_REQUIRED_MODULES := $(required_modules)

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CLANG := true
LOCAL_SRC_FILES := vdc.cpp
LOCAL_MODULE := vdc
LOCAL_SHARED_LIBRARIES := libcutils libbase
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)
LOCAL_INIT_RC := vdc.rc

include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)

LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CLANG := true
LOCAL_SRC_FILES:= secdiscard.cpp
LOCAL_MODULE:= secdiscard
LOCAL_SHARED_LIBRARIES := libbase
LOCAL_CFLAGS := $(vold_cflags)
LOCAL_CONLYFLAGS := $(vold_conlyflags)

include $(BUILD_EXECUTABLE)

include $(LOCAL_PATH)/tests/Android.mk
