################################################################################
#
# telinit
#
################################################################################

TELINIT__EXPRV =

# kill programs
TELINIT__PKILL = $(call qstrip,$(BR2_PACKAGE_TELINIT_KILL_PROGS_LIST))
ifeq ($(BR2_PACKAGE_TELINIT_KILL_PROGS_KNOWN),y)
ifeq ($(BR2_PACKAGE_DROPBEAR),y)
TELINIT__PKILL += dropbear
endif
endif
TELINIT__EXPRV += -e 's,@@PROGS_TO_KILL@@,$(call qstrip,$(TELINIT__PKILL)),g'


define TELINIT_EXTRACT_CMDS
	cp -- $(TELINIT_PKGDIR)/telinit.sh.in $(@D)/telinit.sh.in
endef

define TELINIT_BUILD_CMDS
	< $(@D)/telinit.sh.in sed -r $(TELINIT__EXPRV) > $(@D)/telinit
endef

define TELINIT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/telinit $(TARGET_DIR)/$(BR2_PACKAGE_TELINIT_PATH)
endef

$(eval $(virtual-package))
