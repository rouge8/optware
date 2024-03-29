###########################################################
#
# alsa-utils
#
###########################################################

# You must replace "alsa-utils" and "ALSA-UTILS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ALSA-UTILS_VERSION, ALSA-UTILS_SITE and ALSA-UTILS_SOURCE define
# the upstream location of the source code for the package.
# ALSA-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# ALSA-UTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ALSA-UTILS_SITE=ftp://ftp.alsa-project.org/pub/utils
ALSA-UTILS_VERSION=1.0.8
ALSA-UTILS_SOURCE=alsa-utils-$(ALSA-UTILS_VERSION).tar.bz2
ALSA-UTILS_DIR=alsa-utils-$(ALSA-UTILS_VERSION)
ALSA-UTILS_UNZIP=bzcat

#
# ALSA-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
ALSA-UTILS_IPK_VERSION=1

#
# ALSA-UTILS_CONFFILES should be a list of user-editable files
ALSA-UTILS_CONFFILES=

#
# ALSA-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ALSA-UTILS_PATCHES=/dev/null

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ALSA-UTILS_CPPFLAGS=
ALSA-UTILS_LDFLAGS=

#
# ALSA-UTILS_BUILD_DIR is the directory in which the build is done.
# ALSA-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ALSA-UTILS_IPK_DIR is the directory in which the ipk is built.
# ALSA-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ALSA-UTILS_BUILD_DIR=$(BUILD_DIR)/alsa-utils
ALSA-UTILS_SOURCE_DIR=$(SOURCE_DIR)/alsa-utils
ALSA-UTILS_IPK_DIR=$(BUILD_DIR)/alsa-utils-$(ALSA-UTILS_VERSION)-ipk
ALSA-UTILS_IPK=$(BUILD_DIR)/alsa-utils_$(ALSA-UTILS_VERSION)-$(ALSA-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ALSA-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ALSA-UTILS_SITE)/$(ALSA-UTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
alsa-utils-source: $(DL_DIR)/$(ALSA-UTILS_SOURCE) $(ALSA-UTILS_PATCHES)

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
$(ALSA-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(ALSA-UTILS_SOURCE) $(ALSA-UTILS_PATCHES)
	$(MAKE) alsa-lib-stage gettext-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(ALSA-UTILS_DIR) $(ALSA-UTILS_BUILD_DIR)
	$(ALSA-UTILS_UNZIP) $(DL_DIR)/$(ALSA-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ALSA-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(ALSA-UTILS_DIR) -p1
	mv $(BUILD_DIR)/$(ALSA-UTILS_DIR) $(ALSA-UTILS_BUILD_DIR)
	(cd $(ALSA-UTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ALSA-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ALSA-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(ALSA-UTILS_BUILD_DIR)/.configured

alsa-utils-unpack: $(ALSA-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ALSA-UTILS_BUILD_DIR)/.built: $(ALSA-UTILS_BUILD_DIR)/.configured
	rm -f $(ALSA-UTILS_BUILD_DIR)/.built
	$(MAKE) -C $(ALSA-UTILS_BUILD_DIR)
	touch $(ALSA-UTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
alsa-utils: $(ALSA-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ALSA-UTILS_BUILD_DIR)/.staged: $(ALSA-UTILS_BUILD_DIR)/.built
	rm -f $(ALSA-UTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(ALSA-UTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ALSA-UTILS_BUILD_DIR)/.staged

alsa-utils-stage: $(ALSA-UTILS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ALSA-UTILS_IPK_DIR)/opt/sbin or $(ALSA-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ALSA-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ALSA-UTILS_IPK_DIR)/opt/etc/alsa-utils/...
# Documentation files should be installed in $(ALSA-UTILS_IPK_DIR)/opt/doc/alsa-utils/...
# Daemon startup scripts should be installed in $(ALSA-UTILS_IPK_DIR)/opt/etc/init.d/S??alsa-utils
#
# You may need to patch your application to make it use these locations.
#
$(ALSA-UTILS_IPK): $(ALSA-UTILS_BUILD_DIR)/.built
	rm -rf $(ALSA-UTILS_IPK_DIR) $(BUILD_DIR)/alsa-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ALSA-UTILS_BUILD_DIR) DESTDIR=$(ALSA-UTILS_IPK_DIR) install
	install -d $(ALSA-UTILS_IPK_DIR)/CONTROL
	install -m 644 $(ALSA-UTILS_SOURCE_DIR)/control $(ALSA-UTILS_IPK_DIR)/CONTROL/control
	echo $(ALSA-UTILS_CONFFILES) | sed -e 's/ /\n/g' > $(ALSA-UTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ALSA-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
alsa-utils-ipk: $(ALSA-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
alsa-utils-clean:
	-$(MAKE) -C $(ALSA-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
alsa-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(ALSA-UTILS_DIR) $(ALSA-UTILS_BUILD_DIR) $(ALSA-UTILS_IPK_DIR) $(ALSA-UTILS_IPK)
