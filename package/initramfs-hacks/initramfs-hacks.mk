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
	## replace /etc/dropbear symlink with directory
	$(call INITRAMFS_HACKS__DROP_SYM,/etc/dropbear)
	$(INSTALL) -d -m 0700 -- $(TARGET_DIR)/etc/dropbear
endef
INITRAMFS_HACKS_TARGET_FINALIZE_HOOKS += INITRAMFS_HACKS_DO_DROPBEAR_CONFDIR

# import dropbear RSA host key
INITRAMFS_HACKS__DROPBEAR_CONFDIR_HOST_KEY_RSA_SRC = \
	$(call qstrip,$(BR2_PACKAGE_INITRAMFS_HACKS_DROPBEAR_CONFDIR_HOST_KEY_RSA))

ifeq ($(INITRAMFS_HACKS__DROPBEAR_CONFDIR_HOST_KEY_RSA_SRC),)
else
define INITRAMFS_HACKS_DO_DROPBEAR_CONFDIR_HOST_KEY_RSA
	## install dropbear RSA host key
	$(INSTALL) -m 0400 -- \
		'$(INITRAMFS_HACKS__DROPBEAR_CONFDIR_HOST_KEY_RSA_SRC)' \
		$(TARGET_DIR)/etc/dropbear/dropbear_rsa_host_key
endef
INITRAMFS_HACKS_TARGET_FINALIZE_HOOKS += INITRAMFS_HACKS_DO_DROPBEAR_CONFDIR_HOST_KEY_RSA
endif

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
