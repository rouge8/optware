#
# Make file for sudo
#
# $Id$

SUDO_SITE=http://probsd.org/sudoftp
#SUDO_SITE=http://sources.nslu2-linux.org/sources/
SUDO_VERSION=1.6.8p12
SUDO_SOURCE=sudo-$(SUDO_VERSION).tar.gz
SUDO_DIR=sudo-$(SUDO_VERSION)
SUDO_UNZIP=zcat
SUDO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SUDO_DESCRIPTION=System utility to execute commands as the superuser
SUDO_SECTION=sysutil
SUDO_PRIORITY=optional
SUDO_DEPENDS=
SUDO_SUGGESTS=
SUDO_CONFLICTS=

SUDO_IPK_VERSION=7

SUDO_CONFFILES=/opt/etc/sudoers

ifeq ($(OPTWARE_TARGET),wl500g)
SUDO_PATCHES=$(SUDO_SOURCE_DIR)/configure.patch $(SUDO_SOURCE_DIR)/configure_wl500g.patch
else
SUDO_PATCHES=$(SUDO_SOURCE_DIR)/configure.patch
endif

SUDO_BUILD_DIR:=$(BUILD_DIR)/sudo
SUDO_SOURCE_DIR=$(SOURCE_DIR)/sudo
SUDO_IPK_DIR=$(BUILD_DIR)/sudo-$(SUDO_VERSION)-ipk
SUDO_IPK=$(BUILD_DIR)/sudo_$(SUDO_VERSION)-$(SUDO_IPK_VERSION)_$(TARGET_ARCH).ipk


$(DL_DIR)/$(SUDO_SOURCE):
	cd $(DL_DIR) && $(WGET) $(SUDO_SITE)/$(SUDO_SOURCE)

sudo-source: $(DL_DIR)/$(SUDO_SOURCE) $(SUDO_PATCHES)

$(SUDO_BUILD_DIR)/.configured: $(DL_DIR)/$(SUDO_SOURCE) $(SUDO_PATCHES)
	rm -rf $(BUILD_DIR)/$(SUDO_DIR) $(SUDO_BUILD_DIR)
	$(SUDO_UNZIP) $(DL_DIR)/$(SUDO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SUDO_PATCHES) | patch -d $(BUILD_DIR)/$(SUDO_DIR) -p1
	mv $(BUILD_DIR)/$(SUDO_DIR) $(SUDO_BUILD_DIR)
	cd $(SUDO_BUILD_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--target=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/opt \
			--enable-authentication \
			--without-insults \
			--with-editor=/bin/vi \
			--sysconfdir=/opt/etc
	touch $(SUDO_BUILD_DIR)/.configured

sudo-unpack: $(SUDO_BUILD_DIR)/.configured

$(SUDO_BUILD_DIR)/sudo: $(SUDO_BUILD_DIR)/.configured
	make -C $(SUDO_BUILD_DIR)

sudo: $(SUDO_BUILD_DIR)/sudo

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sudo
#
$(SUDO_IPK_DIR)/CONTROL/control:
	@install -d $(SUDO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: sudo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SUDO_PRIORITY)" >>$@
	@echo "Section: $(SUDO_SECTION)" >>$@
	@echo "Version: $(SUDO_VERSION)-$(SUDO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SUDO_MAINTAINER)" >>$@
	@echo "Source: $(SUDO_SITE)/$(SUDO_SOURCE)" >>$@
	@echo "Description: $(SUDO_DESCRIPTION)" >>$@
	@echo "Depends: $(SUDO_DEPENDS)" >>$@
	@echo "Suggests: $(SUDO_SUGGESTS)" >>$@
	@echo "Conflicts: $(SUDO_CONFLICTS)" >>$@

$(SUDO_IPK): $(SUDO_BUILD_DIR)/sudo
	rm -rf $(SUDO_IPK_DIR) $(BUILD_DIR)/sudo_*_$(TARGET_ARCH).ipk
	install -d $(SUDO_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(SUDO_BUILD_DIR)/sudo -o $(SUDO_IPK_DIR)/opt/bin/sudo
	$(STRIP_COMMAND) $(SUDO_BUILD_DIR)/visudo -o $(SUDO_IPK_DIR)/opt/bin/visudo
	install -d $(SUDO_IPK_DIR)/opt/etc
	install -m 600 $(SUDO_BUILD_DIR)/sudoers $(SUDO_IPK_DIR)/opt/etc/sudoers
	install -d $(SUDO_IPK_DIR)/opt/doc/sudo
	install -m 644 $(SUDO_BUILD_DIR)/sample.sudoers $(SUDO_IPK_DIR)/opt/doc/sudo/sample.sudoers
	$(MAKE) $(SUDO_IPK_DIR)/CONTROL/control
	install -m 644 $(SUDO_SOURCE_DIR)/postinst $(SUDO_IPK_DIR)/CONTROL/postinst
	echo $(SUDO_CONFFILES) | sed -e 's/ /\n/g' > $(SUDO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR) && $(IPKG_BUILD) $(SUDO_IPK_DIR)


sudo-ipk: $(SUDO_IPK)

sudo-clean:
	-make -C $(SUDO_BUILD_DIR) clean

sudo-dirclean:
	rm -rf $(BUILD_DIR)/$(SUDO_DIR) $(SUDO_BUILD_DIR) $(SUDO_IPK_DIR) $(SUDO_IPK)
