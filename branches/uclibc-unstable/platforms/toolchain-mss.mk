TARGET_ARCH=mipsel
TARGET_OS=linux

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = mipsel-linux
CROSS_CONFIGURATION = hndtools-mipsel-linux
TARGET_CROSS = /opt/brcm/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/brcm/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
