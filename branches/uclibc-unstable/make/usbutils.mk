###########################################################
#
# usbutils
#
###########################################################

#
# USBUTILS_VERSION, USBUTILS_SITE and USBUTILS_SOURCE define
# the upstream location of the source code for the package.
# USBUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# USBUTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
USBUTILS_SITE=http://wwwbode.cs.tum.edu/Par/arch/usb/download/usbutils
USBUTILS_VERSION=0.11
USBUTILS_SOURCE=usbutils-$(USBUTILS_VERSION).tar.gz
USBUTILS_DIR=usbutils-$(USBUTILS_VERSION)
USBUTILS_UNZIP=zcat
USBUTILS_PRIORITY=optional
USBUTILS_DEPENDS=
USBUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
USBUTILS_SECTION=utility
USBUTILS_DESCRIPTION=USB enumeration utilities


#
# USBUTILS_IPK_VERSION should be incremented when the ipk changes.
#
USBUTILS_IPK_VERSION=2

#
# USBUTILS_CONFFILES should be a list of user-editable files
#USBUTILS_CONFFILES=/opt/etc/usbutils.conf /opt/etc/init.d/SXXusbutils

#
# USBUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
USBUTILS_PATCHES=$(USBUTILS_SOURCE_DIR)/lsusb-endian.patch \
	$(USBUTILS_SOURCE_DIR)/lsusb-wchar-unused.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
USBUTILS_CPPFLAGS=
USBUTILS_LDFLAGS=

#
# USBUTILS_BUILD_DIR is the directory in which the build is done.
# USBUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# USBUTILS_IPK_DIR is the directory in which the ipk is built.
# USBUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
USBUTILS_BUILD_DIR=$(BUILD_DIR)/usbutils
USBUTILS_SOURCE_DIR=$(SOURCE_DIR)/usbutils
USBUTILS_IPK_DIR=$(BUILD_DIR)/usbutils-$(USBUTILS_VERSION)-ipk
USBUTILS_IPK=$(BUILD_DIR)/usbutils_$(USBUTILS_VERSION)-$(USBUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(USBUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(USBUTILS_SITE)/$(USBUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
usbutils-source: $(DL_DIR)/$(USBUTILS_SOURCE) $(USBUTILS_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(USBUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(USBUTILS_SOURCE) $(USBUTILS_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(USBUTILS_DIR) $(USBUTILS_BUILD_DIR)
	$(USBUTILS_UNZIP) $(DL_DIR)/$(USBUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(USBUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(USBUTILS_DIR) -p1
	mv $(BUILD_DIR)/$(USBUTILS_DIR) $(USBUTILS_BUILD_DIR)
	(cd $(USBUTILS_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(USBUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(USBUTILS_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--datadir=/opt/share/misc \
	)
	touch $(USBUTILS_BUILD_DIR)/.configured

usbutils-unpack: $(USBUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(USBUTILS_BUILD_DIR)/.built: $(USBUTILS_BUILD_DIR)/.configured
	rm -f $(USBUTILS_BUILD_DIR)/.built
	$(MAKE) -C $(USBUTILS_BUILD_DIR)
	touch $(USBUTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
usbutils: $(USBUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(USBUTILS_BUILD_DIR)/.staged: $(USBUTILS_BUILD_DIR)/.built
	rm -f $(USBUTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(USBUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(USBUTILS_BUILD_DIR)/.staged

usbutils-stage: $(USBUTILS_BUILD_DIR)/.staged

# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/usbutils
#
$(USBUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(USBUTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: usbutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(USBUTILS_PRIORITY)" >>$@
	@echo "Section: $(USBUTILS_SECTION)" >>$@
	@echo "Version: $(USBUTILS_VERSION)-$(USBUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(USBUTILS_MAINTAINER)" >>$@
	@echo "Source: $(USBUTILS_SITE)/$(USBUTILS_SOURCE)" >>$@
	@echo "Description: $(USBUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(USBUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(USBUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(USBUTILS_IPK_DIR)/opt/sbin or $(USBUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(USBUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(USBUTILS_IPK_DIR)/opt/etc/usbutils/...
# Documentation files should be installed in $(USBUTILS_IPK_DIR)/opt/doc/usbutils/...
# Daemon startup scripts should be installed in $(USBUTILS_IPK_DIR)/opt/etc/init.d/S??usbutils
#
# You may need to patch your application to make it use these locations.
#
$(USBUTILS_IPK): $(USBUTILS_BUILD_DIR)/.built
	rm -rf $(USBUTILS_IPK_DIR) $(BUILD_DIR)/usbutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(USBUTILS_BUILD_DIR) DESTDIR=$(USBUTILS_IPK_DIR) install-strip
	# don't want these as they conflict with real libusb
	rm -rf $(USBUTILS_IPK_DIR)/opt/lib $(USBUTILS_IPK_DIR)/opt/include
#	install -d $(USBUTILS_IPK_DIR)/opt/etc/
#	install -m 644 $(USBUTILS_SOURCE_DIR)/usbutils.conf $(USBUTILS_IPK_DIR)/opt/etc/usbutils.conf
#	install -d $(USBUTILS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(USBUTILS_SOURCE_DIR)/rc.usbutils $(USBUTILS_IPK_DIR)/opt/etc/init.d/SXXusbutils
	$(MAKE) $(USBUTILS_IPK_DIR)/CONTROL/control
#	install -m 755 $(USBUTILS_SOURCE_DIR)/postinst $(USBUTILS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(USBUTILS_SOURCE_DIR)/prerm $(USBUTILS_IPK_DIR)/CONTROL/prerm
#	echo $(USBUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(USBUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(USBUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
usbutils-ipk: $(USBUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
usbutils-clean:
	-$(MAKE) -C $(USBUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
usbutils-dirclean:
	rm -rf $(BUILD_DIR)/$(USBUTILS_DIR) $(USBUTILS_BUILD_DIR) $(USBUTILS_IPK_DIR) $(USBUTILS_IPK)
