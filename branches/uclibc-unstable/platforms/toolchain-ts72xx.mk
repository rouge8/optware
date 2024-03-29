TARGET_ARCH=arm
TARGET_OS=linux

CROSSTOOL_SCRIPT = ts72xx-cross334.sh
CROSSTOOL-NATIVE_SCRIPT = ts72xx-native334.sh

CROSS_CONFIGURATION_GCC_VERSION=3.3.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.3.2
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
