###########################################################
#
# perl-universal-moniker
#
###########################################################

PERL-UNIVERSAL-MONIKER_SITE=http://search.cpan.org/CPAN/authors/id/K/KA/KASEI
PERL-UNIVERSAL-MONIKER_VERSION=0.08
PERL-UNIVERSAL-MONIKER_SOURCE=UNIVERSAL-moniker-$(PERL-UNIVERSAL-MONIKER_VERSION).tar.gz
PERL-UNIVERSAL-MONIKER_DIR=UNIVERSAL-moniker-$(PERL-UNIVERSAL-MONIKER_VERSION)
PERL-UNIVERSAL-MONIKER_UNZIP=zcat
PERL-UNIVERSAL-MONIKER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-UNIVERSAL-MONIKER_DESCRIPTION=UNIVERSAL-moniker - This module will add a moniker (and plural_moniker) method to UNIVERSAL, and so to every class or module.
PERL-UNIVERSAL-MONIKER_SECTION=util
PERL-UNIVERSAL-MONIKER_PRIORITY=optional
PERL-UNIVERSAL-MONIKER_DEPENDS=perl
PERL-UNIVERSAL-MONIKER_SUGGESTS=
PERL-UNIVERSAL-MONIKER_CONFLICTS=

PERL-UNIVERSAL-MONIKER_IPK_VERSION=1

PERL-UNIVERSAL-MONIKER_CONFFILES=

PERL-UNIVERSAL-MONIKER_BUILD_DIR=$(BUILD_DIR)/perl-universal-moniker
PERL-UNIVERSAL-MONIKER_SOURCE_DIR=$(SOURCE_DIR)/perl-universal-moniker
PERL-UNIVERSAL-MONIKER_IPK_DIR=$(BUILD_DIR)/perl-universal-moniker-$(PERL-UNIVERSAL-MONIKER_VERSION)-ipk
PERL-UNIVERSAL-MONIKER_IPK=$(BUILD_DIR)/perl-universal-moniker_$(PERL-UNIVERSAL-MONIKER_VERSION)-$(PERL-UNIVERSAL-MONIKER_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-UNIVERSAL-MONIKER_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-UNIVERSAL-MONIKER_SITE)/$(PERL-UNIVERSAL-MONIKER_SOURCE)

perl-universal-moniker-source: $(DL_DIR)/$(PERL-UNIVERSAL-MONIKER_SOURCE) $(PERL-UNIVERSAL-MONIKER_PATCHES)

$(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-UNIVERSAL-MONIKER_SOURCE) $(PERL-UNIVERSAL-MONIKER_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-UNIVERSAL-MONIKER_DIR) $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)
	$(PERL-UNIVERSAL-MONIKER_UNZIP) $(DL_DIR)/$(PERL-UNIVERSAL-MONIKER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-UNIVERSAL-MONIKER_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-UNIVERSAL-MONIKER_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-UNIVERSAL-MONIKER_DIR) $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)
	(cd $(PERL-UNIVERSAL-MONIKER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.configured

perl-universal-moniker-unpack: $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.configured

$(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.built: $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.configured
	rm -f $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-UNIVERSAL-MONIKER_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.built

perl-universal-moniker: $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.built

$(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.staged: $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.built
	rm -f $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-UNIVERSAL-MONIKER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.staged

perl-universal-moniker-stage: $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.staged

$(PERL-UNIVERSAL-MONIKER_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-UNIVERSAL-MONIKER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-universal-moniker" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-UNIVERSAL-MONIKER_PRIORITY)" >>$@
	@echo "Section: $(PERL-UNIVERSAL-MONIKER_SECTION)" >>$@
	@echo "Version: $(PERL-UNIVERSAL-MONIKER_VERSION)-$(PERL-UNIVERSAL-MONIKER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-UNIVERSAL-MONIKER_MAINTAINER)" >>$@
	@echo "Source: $(PERL-UNIVERSAL-MONIKER_SITE)/$(PERL-UNIVERSAL-MONIKER_SOURCE)" >>$@
	@echo "Description: $(PERL-UNIVERSAL-MONIKER_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-UNIVERSAL-MONIKER_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-UNIVERSAL-MONIKER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-UNIVERSAL-MONIKER_CONFLICTS)" >>$@

$(PERL-UNIVERSAL-MONIKER_IPK): $(PERL-UNIVERSAL-MONIKER_BUILD_DIR)/.built
	rm -rf $(PERL-UNIVERSAL-MONIKER_IPK_DIR) $(BUILD_DIR)/perl-universal-moniker_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-UNIVERSAL-MONIKER_BUILD_DIR) DESTDIR=$(PERL-UNIVERSAL-MONIKER_IPK_DIR) install
	find $(PERL-UNIVERSAL-MONIKER_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-UNIVERSAL-MONIKER_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-UNIVERSAL-MONIKER_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-UNIVERSAL-MONIKER_IPK_DIR)/CONTROL/control
	echo $(PERL-UNIVERSAL-MONIKER_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-UNIVERSAL-MONIKER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-UNIVERSAL-MONIKER_IPK_DIR)

perl-universal-moniker-ipk: $(PERL-UNIVERSAL-MONIKER_IPK)

perl-universal-moniker-clean:
	-$(MAKE) -C $(PERL-UNIVERSAL-MONIKER_BUILD_DIR) clean

perl-universal-moniker-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-UNIVERSAL-MONIKER_DIR) $(PERL-UNIVERSAL-MONIKER_BUILD_DIR) $(PERL-UNIVERSAL-MONIKER_IPK_DIR) $(PERL-UNIVERSAL-MONIKER_IPK)
