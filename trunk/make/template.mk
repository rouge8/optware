###########################################################
#
# <foo>
#
###########################################################

# You must replace "<foo>" and "<FOO>" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# <FOO>_VERSION, <FOO>_SITE and <FOO>_SOURCE define
# the upstream location of the source code for the package.
# <FOO>_DIR is the directory which is created when the source
# archive is unpacked.
# <FOO>_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
<FOO>_SITE=http://www.<foo>.org/downloads
<FOO>_VERSION=3.2.3
<FOO>_SOURCE=<foo>-$(<FOO>_VERSION).tar.gz
<FOO>_DIR=<foo>-$(<FOO>_VERSION)
<FOO>_UNZIP=zcat

#
# <FOO>_IPK_VERSION should be incremented when the ipk changes.
#
<FOO>_IPK_VERSION=1

#
# <FOO>_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
<FOO>_PATCHES=$(<FOO>_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
<FOO>_CPPFLAGS=
<FOO>_LDFLAGS=

#
# <FOO>_BUILD_DIR is the directory in which the build is done.
# <FOO>_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# <FOO>_IPK_DIR is the directory in which the ipk is built.
# <FOO>_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
<FOO>_BUILD_DIR=$(BUILD_DIR)/<foo>
<FOO>_SOURCE_DIR=$(SOURCE_DIR)/<foo>
<FOO>_IPK_DIR=$(BUILD_DIR)/<foo>-$(<FOO>_VERSION)-ipk
<FOO>_IPK=$(BUILD_DIR)/<foo>_$(<FOO>_VERSION)-$(<FOO>_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(<FOO>_SOURCE):
	$(WGET) -P $(DL_DIR) $(<FOO>_SITE)/$(<FOO>_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
<foo>-source: $(DL_DIR)/$(<FOO>_SOURCE) $(<FOO>_PATCHES)

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
$(<FOO>_BUILD_DIR)/.configured: $(DL_DIR)/$(<FOO>_SOURCE) $(<FOO>_PATCHES)
	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(<FOO>_DIR) $(<FOO>_BUILD_DIR)
	$(<FOO>_UNZIP) $(DL_DIR)/$(<FOO>_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(<FOO>_PATCHES) | patch -d $(BUILD_DIR)/$(<FOO>_DIR) -p1
	mv $(BUILD_DIR)/$(<FOO>_DIR) $(<FOO>_BUILD_DIR)
	(cd $(<FOO>_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(<FOO>_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(<FOO>_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(<FOO>_BUILD_DIR)/.configured

<foo>-unpack: $(<FOO>_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(<FOO>_BUILD_DIR)/.built: $(<FOO>_BUILD_DIR)/.configured
	rm -f $(<FOO>_BUILD_DIR)/.built
	$(MAKE) -C $(<FOO>_BUILD_DIR)
	touch $(<FOO>_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
<foo>: $(<FOO>_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/lib<foo>.so.$(<FOO>_VERSION): $(<FOO>_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(<FOO>_BUILD_DIR)/<foo>.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(<FOO>_BUILD_DIR)/lib<foo>.a $(STAGING_DIR)/opt/lib
	install -m 644 $(<FOO>_BUILD_DIR)/lib<foo>.so.$(<FOO>_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs lib<foo>.so.$(<FOO>_VERSION) lib<foo>.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs lib<foo>.so.$(<FOO>_VERSION) lib<foo>.so

<foo>-stage: $(STAGING_DIR)/opt/lib/lib<foo>.so.$(<FOO>_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(<FOO>_IPK_DIR)/opt/sbin or $(<FOO>_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(<FOO>_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(<FOO>_IPK_DIR)/opt/etc/<foo>/...
# Documentation files should be installed in $(<FOO>_IPK_DIR)/opt/doc/<foo>/...
# Daemon startup scripts should be installed in $(<FOO>_IPK_DIR)/opt/etc/init.d/S??<foo>
#
# You may need to patch your application to make it use these locations.
#
$(<FOO>_IPK): $(<FOO>_BUILD_DIR)/.built
	rm -rf $(<FOO>_IPK_DIR) $(<FOO>_IPK)
	install -d $(<FOO>_IPK_DIR)/opt/bin
	$(TARGET_STRIP) $(<FOO>_BUILD_DIR)/<foo> -o $(<FOO>_IPK_DIR)/opt/bin/<foo>
	install -d $(<FOO>_IPK_DIR)/opt/etc/init.d
	install -m 755 $(<FOO>_SOURCE_DIR)/rc.<foo> $(<FOO>_IPK_DIR)/opt/etc/init.d/SXX<foo>
	install -d $(<FOO>_IPK_DIR)/CONTROL
	install -m 644 $(<FOO>_SOURCE_DIR)/control $(<FOO>_IPK_DIR)/CONTROL/control
	install -m 644 $(<FOO>_SOURCE_DIR)/postinst $(<FOO>_IPK_DIR)/CONTROL/postinst
	install -m 644 $(<FOO>_SOURCE_DIR)/prerm $(<FOO>_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(<FOO>_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
<foo>-ipk: $(<FOO>_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
<foo>-clean:
	-$(MAKE) -C $(<FOO>_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
<foo>-dirclean:
	rm -rf $(BUILD_DIR)/$(<FOO>_DIR) $(<FOO>_BUILD_DIR) $(<FOO>_IPK_DIR) $(<FOO>_IPK)
