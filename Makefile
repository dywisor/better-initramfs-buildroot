SHELL ?= sh

S := $(abspath $(CURDIR))

REPO_NAME = dywi/better-initramfs-buildroot
REPO_ROOT = $(S)
REPO_PKG = $(REPO_ROOT:/=)/package

PHONY =

PHONY += default
default: list-pkg

include $(S)/br_pkg_repo.mk

FORCE:

.PHONY: $(PHONY)
