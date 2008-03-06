LIBC_STYLE=uclibc
TARGET_ARCH=arm
TARGET_OS=linux-uclibc

LIBSTDC++_VERSION=5.0.5
LIBNSL_VERSION=0.9.28

GETTEXT_NLS=enable
NO_BUILTIN_MATH=true

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME=$(TARGET_ARCH)-linux

CROSS_CONFIGURATION_GCC_VERSION=3.3.3
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.28
BUILDROOT_GCC=$(CROSS_CONFIGURATION_GCC_VERSION)
UCLIBC-OPT_VERSION=$(CROSS_CONFIGURATION_UCLIBC_VERSION)

ifeq ($(HOST_MACHINE),arm)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(HOST_MACHINE)-linux-gnu
TARGET_CROSS=/opt/bin/
TARGET_LIBDIR=/opt/lib
TARGET_INCDIR=/opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
TOOLCHAIN_UCLIBC_SITE=ftp://ftp.dlink.com/GPL/DNS-323/
TOOLCHAIN_UCLIBC_DIR=uclibc-toolchain-src-20040609
TOOLCHAIN_UCLIBC_SOURCE=$(TOOLCHAIN_UCLIBC_DIR).tgz

TOOLCHAIN_BUILD_DIR=$(BASE_DIR)/toolchain/$(TOOLCHAIN_UCLIBC_DIR)/gcc-3.3.x
TOOLCHAIN_SOURCE_DIR=$(SOURCE_DIR)/toolchain-dns323

CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
TARGET_CROSS_TOP = $(TOOLCHAIN_UNPACK_DIR)/gcc-3.3.x/toolchain_arm
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(TARGET_ARCH)-$(TARGET_OS)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/arm-linux-uclibc/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/arm-linux-uclibc/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

$(DL_DIR)/$(TOOLCHAIN_UCLIBC_SOURCE):
	$(WGET) -P $(DL_DIR) $(TOOLCHAIN_UCLIBC_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

$(TOOLCHAIN_BUILD_DIR)/.unpacked: $(DL_DIR)/$(TOOLCHAIN_UCLIBC_SOURCE)
	rm -rf $(@D)
	tar -C $(BASE_DIR)/toolchain -xzf $(DL_DIR)/$(TOOLCHAIN_UCLIBC_SOURCE)
	rm -f `find $(@D)/.. -name .unpacked`
	cp -f $(TOOLCHAIN_SOURCE_DIR)/uClibc.config $(@D)/sources/
	patch -d $(@D) -p0 < $(TOOLCHAIN_SOURCE_DIR)/kernel-headers.mk.patch
	cp -f $(TOOLCHAIN_SOURCE_DIR)/gcc-*.patch $(@D)/sources/
	cp -f $(TOOLCHAIN_SOURCE_DIR)/gdb-*.patch $(@D)/sources/
	touch $@

toolchain-unpack: $(TOOLCHAIN_BUILD_DIR)/.unpacked

$(TOOLCHAIN_BUILD_DIR)/.built: $(TOOLCHAIN_BUILD_DIR)/.unpacked
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

toolchain: $(TOOLCHAIN_BUILD_DIR)/.built
endif
