################################################################################
#
# askpass
#
################################################################################

ASKPASS_VERSION       = 2012
ASKPASS_SOURCE        = askpass.c
ASKPASS_SITE          = https://bitbucket.org/piotrkarbowski/better-initramfs/downloads
ASKPASS_LICENSE       = GPLv2+
#ASKPASS_LICENSE_FILES =

define ASKPASS_EXTRACT_CMDS
	cp -- $(ASKPASS_DL_DIR)/$($(PKG)_SOURCE) $(@D)/
endef

define ASKPASS_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) askpass
endef

define ASKPASS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 -- $(@D)/askpass $(TARGET_DIR)/usr/bin/askpass
endef

$(eval $(generic-package))
