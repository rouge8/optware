###########################################################
#
# nano
#
###########################################################

NANO_SITE=http://www.nano-editor.org/dist/v2.0
NANO_VERSION=2.0.3
NANO_SOURCE=nano-$(NANO_VERSION).tar.gz
NANO_DIR=nano-$(NANO_VERSION)
NANO_UNZIP=zcat
NANO_MAINTAINER=Mark Donszelmann <mark@donszelmann.com>
NANO_DESCRIPTION=A pico like editor
NANO_SECTION=editor
NANO_PRIORITY=optional
NANO_DEPENDS=ncurses
NANO_CONFLICTS=

NANO_IPK_VERSION=1

#NANO_CONFFILES=/opt/etc/nanorc

#NANO_PATCHES=$(NANO_SOURCE_DIR)/broken_regex.patch

NANO_CPPFLAGS=-I$(STAGING_PREFIX)/include/ncurses
NANO_LDFLAGS=

NANO_BUILD_DIR=$(BUILD_DIR)/nano
NANO_SOURCE_DIR=$(SOURCE_DIR)/nano
NANO_IPK_DIR=$(BUILD_DIR)/nano-$(NANO_VERSION)-ipk
NANO_IPK=$(BUILD_DIR)/nano_$(NANO_VERSION)-$(NANO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nano-source nano-unpack nano nano-stage nano-ipk nano-clean nano-dirclean nano-check

$(DL_DIR)/$(NANO_SOURCE):
	$(WGET) -P $(DL_DIR) $(NANO_SITE)/$(NANO_SOURCE)

nano-source: $(DL_DIR)/$(NANO_SOURCE) $(NANO_PATCHES)

$(NANO_BUILD_DIR)/.configured: $(DL_DIR)/$(NANO_SOURCE) $(NANO_PATCHES) make/nano.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR)
	$(NANO_UNZIP) $(DL_DIR)/$(NANO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NANO_PATCHES)"; \
		then cat $(NANO_PATCHES) | patch -d $(BUILD_DIR)/$(NANO_DIR); \
	fi
	mv $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR)
	(cd $(NANO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NANO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NANO_LDFLAGS)" \
		ac_cv_lib_ncursesw_get_wch=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-all \
		--without-libiconv-prefix \
		--disable-utf8 \
		--disable-nls \
	)
	touch $(NANO_BUILD_DIR)/.configured

nano-unpack: $(NANO_BUILD_DIR)/.configured

$(NANO_BUILD_DIR)/.built: $(NANO_BUILD_DIR)/.configured
	rm -f $(NANO_BUILD_DIR)/.built
	$(MAKE) -C $(NANO_BUILD_DIR)
	touch $(NANO_BUILD_DIR)/.built

nano: $(NANO_BUILD_DIR)/.built

$(NANO_BUILD_DIR)/.staged: $(NANO_BUILD_DIR)/.built
	rm -f $(NANO_BUILD_DIR)/.staged
	$(MAKE) -C $(NANO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NANO_BUILD_DIR)/.staged

nano-stage: $(NANO_BUILD_DIR)/.staged

$(NANO_IPK_DIR)/CONTROL/control:
	@install -d $(NANO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nano" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NANO_PRIORITY)" >>$@
	@echo "Section: $(NANO_SECTION)" >>$@
	@echo "Version: $(NANO_VERSION)-$(NANO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NANO_MAINTAINER)" >>$@
	@echo "Source: $(NANO_SITE)/$(NANO_SOURCE)" >>$@
	@echo "Description: $(NANO_DESCRIPTION)" >>$@
	@echo "Depends: $(NANO_DEPENDS)" >>$@
	@echo "Conflicts: $(NANO_CONFLICTS)" >>$@

$(NANO_IPK): $(NANO_BUILD_DIR)/.built
	rm -rf $(NANO_IPK_DIR) $(BUILD_DIR)/nano_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NANO_BUILD_DIR) DESTDIR=$(NANO_IPK_DIR) program_transform_name="" install-strip
	install -d $(NANO_IPK_DIR)/opt/etc/
	install -m 644 $(NANO_BUILD_DIR)/doc/nanorc.sample $(NANO_IPK_DIR)/opt/etc/nanorc
	$(MAKE) $(NANO_IPK_DIR)/CONTROL/control
	echo $(NANO_CONFFILES) | sed -e 's/ /\n/g' > $(NANO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NANO_IPK_DIR)

nano-ipk: $(NANO_IPK)

nano-clean:
	-$(MAKE) -C $(NANO_BUILD_DIR) clean

nano-dirclean:
	rm -rf $(BUILD_DIR)/$(NANO_DIR) $(NANO_BUILD_DIR) $(NANO_IPK_DIR) $(NANO_IPK)

#
# Some sanity check for the package.
#
nano-check: $(NANO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NANO_IPK)
