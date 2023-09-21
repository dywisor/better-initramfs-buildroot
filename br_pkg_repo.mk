__EMPTY =
__TAB = $(__EMPTY)$(shell printf "\t")$(__EMPTY)

# ---
# http://stackoverflow.com/questions/664601/in-gnu-make-how-do-i-convert-a-variable-to-lower-case
#
#  python code for generating these statements:
#
#  LTU = [ chr(i) for i in range ( 0x61, 0x7b ) ]
#  UTL = [ c.upper() for c in LTU ]
#
#  f = lambda v: '$(1)' if not v else '$(subst {},{},{})'.format (v[0],v[0].swapcase(),f(v[1:]))
#
## >>> f(UTL) => lc
## >>> f(LTU) => uc

lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$(1)))))))))))))))))))))))))))
uc = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$(1)))))))))))))))))))))))))))

f_convert_name = $(subst -,_,$(subst /,_,$(call uc,$(1))))
# ---

f_find_packages = $(foreach d,$(wildcard $(1)/*/Config.in),$(notdir $(d:%/Config.in=%)))

ifeq ("","$(REPO_NAME)")
$(error REPO_NAME is not set)
endif

ifeq ("","$(REPO_ROOT)")
REPO_ROOT := $(abspath $(CURDIR))
endif

ifeq ("","$(REPO_PKG)")
REPO_PKG := $(REPO_ROOT)/package
endif

PKG_SUBDIR_NAME := $(subst /,__,$(REPO_NAME))

PKG_NAMES := $(call f_find_packages,$(REPO_PKG))


ifeq ("","$(BR)")
HAVE_BR = 0

else
HAVE_BR = 1

_PKG_DIR_IN_BR  := $(BR)/package/$(PKG_SUBDIR_NAME)

_PKG_INSTALL_TARGETS   := $(addprefix $(BR)/package/,$(PKG_NAMES))
_PKG_UNINSTALL_TARGETS := $(addprefix uninstall-$(BR)/package/,$(PKG_NAMES))
endif

PHONY += _error_no_default_target
_error_no_default_target:
	$(error no default target set)


PHONY += sanity-check-repo-base
sanity-check-repo-base:
	test -n '$(REPO_ROOT)'
	test -d '$(REPO_ROOT)'
	test -n '$(REPO_PKG)'
	test -d '$(REPO_PKG)'

PHONY += sanity-check-repo
sanity-check-repo: sanity-check-repo-base
	test -f '$(REPO_PKG)/Config.in'


PHONY += list-pkg list-packages
list-pkg list-packages:
	@{ :; $(foreach w,$(PKG_NAMES), printf '%s\n' '$(w)';) } | sort


PHONY += init-packages
ifeq ("","$(PKGV)")
init-packages:
	$(error PKGV= is empty)
else
init-packages: $(foreach w,$(PKGV),$(REPO_PKG)/$(w) $(REPO_PKG)/$(w)/Config.in $(REPO_PKG)/$(w)/$(w).mk)

$(REPO_PKG):
	mkdir -p -- $@

$(foreach w,$(PKGV),$(REPO_PKG)/$(w)):
	mkdir -p -- $@

f_pname = $(notdir $(patsubst %/,%,$(dir $(1))))
f_pname_mk = $(call f_convert_name,$(call f_pname,$(1)))

$(foreach w,$(PKGV),$(REPO_PKG)/$(w)/Config.in):
# $(REPO_PKG)/%/Config.in -- doesn't work for the mk target below, sadly
	{ set -e; \
		if [ -e '$(@)' ] || [ -h '$(@)' ]; then \
			printf 'Skipping: %s\n' '$(@)' 1>&2; \
		else \
			{ \
				mk_name='$(call f_pname_mk,$@)'; \
				bpkg_name="BR2_PACKAGE_$${mk_name:?}"; \
				\
				printf 'menuconfig %s\n' "$${bpkg_name}"; \
				printf '\tbool "%s"\n' '$(call f_pname,$@)'; \
				printf '\n'; \
				printf '\thelp\n'; \
				printf '\t\t%s\n' 'DESCRIPTION'; \
				printf '\n'; \
				printf '\t\t%s\n' 'URL'; \
				printf '\n'; \
				printf 'if %s\n\n' "$${bpkg_name}"; \
				printf 'config %s_...\n' "$${bpkg_name}"; \
				printf '\n'; \
				printf 'endif %s\n' "# $${bpkg_name}"; \
			} > '$(@).make_tmp'; \
			\
			mv -f -- '$(@).make_tmp' '$(@)'; \
		fi; \
	}

$(foreach w,$(PKGV),$(REPO_PKG)/$(w)/$(w).mk):
	{ set -e; \
		if [ -e '$(@)' ] || [ -h '$(@)' ]; then \
			printf 'Skipping: %s\n' '$(@)' 1>&2; \
		else \
			{ \
				mk_name='$(call f_pname_mk,$@)'; \
				: "$${mk_name:?}"; \
				\
				printf '%s\n' '################################################################################'; \
				printf '%s\n' '#'; \
				printf '%s\n' '# $(call f_pname,$@)'; \
				printf '%s\n' '#'; \
				printf '%s\n' '################################################################################'; \
				printf '\n'; \
				printf '%s_VERSION       =\n' "$${mk_name}"; \
				printf '%s_SOURCE        =\n' "$${mk_name}"; \
				printf '%s_SITE          =\n' "$${mk_name}"; \
				printf '%s_LICENSE       =\n' "$${mk_name}"; \
				printf '%s_LICENSE_FILES =\n' "$${mk_name}"; \
				printf '\n'; \
				printf 'define %s_BUILD_CMDS\n' "$${mk_name}"; \
				printf '\t%s\n' 'false'; \
				printf 'endef\n'; \
				printf '\n'; \
				printf 'define %s_INSTALL_TARGET_CMDS\n' "$${mk_name}"; \
				printf '\t%s\n' 'false'; \
				printf 'endef\n'; \
				printf '\n'; \
				printf '%s\n' '$$(eval $$(generic-package))'; \
			} > '$(@).make_tmp'; \
			\
			mv -f -- '$(@).make_tmp' '$(@)'; \
		fi; \
	}

endif

PHONY += update-config
update-config: $(REPO_PKG)/Config.in

# should not use f_find_packages here
$(REPO_PKG)/Config.in: FORCE sanity-check-repo-base
	mkdir -p -- $(@D)

	{ set -efu; \
		if [ -h '$(@)' ]; then \
			want_gen=0; \
		elif [ -e '$(@)' ]; then \
			if grep -- '^# br_pkg_repo autogen$$' '$(@)' 1>/dev/null; then \
				want_gen=1; \
			else \
				want_gen=0; \
			fi; \
		else \
			printf '%s\n' '# br_pkg_repo autogen' > '$(@)'; \
			want_gen=1; \
		fi; \
		\
		if [ $${want_gen} -eq 1 ]; then \
			{ \
				printf '%s\n' '# br_pkg_repo autogen'; \
				printf 'menu "%s %s"\n' '$(REPO_NAME)' '[external repo]'; \
				find $(REPO_PKG) -mindepth 2 -type f -name '*.mk' -print0 \
					| xargs -0 -r -n 1 -I '{F}' basename '{F}' .mk \
					| sort \
					| xargs -r printf '\tsource "package/%s/Config.in"\n' \
				; \
				printf 'endmenu\n'; \
			} > '$(@).make_tmp'; \
			\
			mv -f -- '$(@).make_tmp' '$(@)'; \
			\
		fi; \
	}

# buildroot srcdir related functionality
#  - install/uninstall package links
#  - register/unregister Config.in
#
ifeq ($(HAVE_BR),1)
PHONY += sanity-check-br
sanity-check-br: sanity-check-repo
	test -d '$(BR)/package'
	test -d '$(dir $(_PKG_DIR_IN_BR))'


# creates the $(_PKG_DIR_IN_BR) symlink
$(_PKG_DIR_IN_BR): sanity-check-br
	test ! -h '$(_PKG_DIR_IN_BR)' || rm -- '$(_PKG_DIR_IN_BR)'
	test ! -e '$(_PKG_DIR_IN_BR)'

	ln -s -- '$(REPO_PKG)' '$(_PKG_DIR_IN_BR)'

# installs a symlink to a specific package in $(_PKG_DIR_IN_BR)
$(_PKG_INSTALL_TARGETS): $(BR)/package/%: $(_PKG_DIR_IN_BR)
	mkdir -p -- $(@D)
	rm -f    -- $@
	ln -s    -- $(PKG_SUBDIR_NAME)/$(*) $@

# removes a symlink to a specific package
PHONY += $(_PKG_UNINSTALL_TARGETS)
$(_PKG_UNINSTALL_TARGETS): uninstall-%:
	rm -f -- $*

# adds a "source <>/Config.in" line to $BR/package/Config.in
PHONY += register-config
register-config: $(_PKG_DIR_IN_BR)
	if grep -E -- \
		'^\s*source\s+\\"?package/$(PKG_SUBDIR_NAME)/Config.in\\"?\s*$$' \
		'$(BR)/package/Config.in'; \
	then \
		echo "Config.in already set up."; \
	else \
		echo "setting up Config.in"; \
		sed \
			-e '$$i\$(__TAB)source "package/$(PKG_SUBDIR_NAME)/Config.in"' \
			-i '$(BR)/package/Config.in'; \
	fi


# undoes "register-config" -- removes "source <>/Config.in"
PHONY += unregister-config
unregister-config:
	sed -r \
		-e '/^\s*source\s+\\"?package\/$(PKG_SUBDIR_NAME)\/Config.in\\"?\s*$$/d' \
		-i '$(BR)/package/Config.in'


# creates the package subdir link, links packages and registers Config.in
PHONY += install
install: $(_PKG_DIR_IN_BR) $(_PKG_INSTALL_TARGETS) register-config


# removes package links/subdir and unregisters Config.in
PHONY += uninstall
uninstall: $(_PKG_UNINSTALL_TARGETS) unregister-config
	rm -f -- $(_PKG_DIR_IN_BR)

else
BR_TARGETS =
BR_TARGETS += sanity-check-br
#BR_TARGETS += $(_PKG_DIR_IN_BR)
#BR_TARGETS += $(_PKG_INSTALL_TARGETS)
#BR_TARGETS += $(_PKG_UNINSTALL_TARGETS)
BR_TARGETS += register-config
BR_TARGETS += unregister-config
BR_TARGETS += install
BR_TARGETS += uninstall

PHONY += $(BR_TARGETS)
$(BR_TARGETS):
	$(error buildroot src dir BR not specified!)

endif

FORCE:

