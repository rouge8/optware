PERL_MAJOR_VER = 5.10

SPECIFIC_PACKAGES = \
        ipkg-opt \
        $(PACKAGES_REQUIRE_LINUX26) \
        $(PERL_PACKAGES) \

BROKEN_PACKAGES = \
        $(PACKAGES_ONLY_WORK_ON_LINUX24) \

ATFTP_EXTRA_PATCHES = $(ATFTP_SOURCE_DIR)/argz.h.patch
