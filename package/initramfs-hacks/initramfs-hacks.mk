################################################################################
#
# initramfs-hacks
#
################################################################################

define INITRAMFS_HACKS__DROP_SYM
	[ ! -h $(TARGET_DIR)$(1) ] || rm -- $(TARGET_DIR)$(1)
endef

define INITRAMFS_HACKS_DO_HEADER
	# initramfs-hacks
endef
INITRAMFS_HACKS_TARGET_FINALIZE_HOOKS += INITRAMFS_HACKS_DO_HEADER


ifeq ($(BR2_PACKAGE_INITRAMFS_HACKS_DROPBEAR_CONFDIR),y)
# dep on dropbear is not needed since this hack is run as finalize hook

define INITRAMFS_HACKS_DO_DROPBEAR_CONFDIR
	$(call INITRAMFS_HACKS__DROP_SYM,/etc/dropbear)
endef
INITRAMFS_HACKS_TARGET_FINALIZE_HOOKS += INITRAMFS_HACKS_DO_DROPBEAR_CONFDIR
endif

ifeq ($(BR2_PACKAGE_INITRAMFS_HACKS_CRYPTSETUP_RUNDIR),y)

define INITRAMFS_HACKS_DO_CRYPTSETUP_RUNDIR
	install -D -d -m 0700 -- $(TARGET_DIR)/run/cryptsetup
endef
INITRAMFS_HACKS_TARGET_FINALIZE_HOOKS += INITRAMFS_HACKS_DO_CRYPTSETUP_RUNDIR
endif


define INITRAMFS_HACKS_DO_FOOTER
	# initramfs-hacks done
endef
INITRAMFS_HACKS_TARGET_FINALIZE_HOOKS += INITRAMFS_HACKS_DO_FOOTER


$(eval $(virtual-package))
