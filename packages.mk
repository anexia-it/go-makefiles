# packages.mk provides the list of go packages and Makefile targets for building
# those packages.
#
# Overridable variables: GO_PACKAGES, GO_BUILD_FLAGS


include $(dir $(lastword $(MAKEFILE_LIST)))/env.mk
include $(dir $(lastword $(MAKEFILE_LIST)))/binaries.mk

# Set GO_PACKAGES condtionally, which allows packages.mk to be included
# multiple times without running the script below multiple times as well.
ifndef GO_PACKAGES
# Use go list to find packages and filter out everything in the vendor
# directory, as well as all binaries
GO_PACKAGES=$(shell $(GO_BIN) list ./... | \
        grep -v '/vendor/' | \
	sed \
                -e 's|^$(GO_ROOT_PACKAGE_NAME)/|./|g' \
                -e 's|^$(GO_ROOT_PACKAGE_NAME)$$|./|g' \
        $(foreach bin,$(GO_BINARIES), -e 's|^$(bin)$$||g' -e 's|^./$(bin)$$||g') \
        )

# Check if any go packages were found
ifeq ($(GO_PACKAGES),)
$(error No Go packages found.)
endif # ifeq ($(GO_PACKAGES),)

# GO_PKG_NAME takes a relative package name and converts it into
# an absolute go package name
define GO_PKG_NAME
$(if $(subst ./,,$1),$(subst ./,$(GO_ROOT_PACKAGE_NAME)/,$1),$(GO_ROOT_PACKAGE_NAME))
endef

# Generate targets for all packages
define _CREATE_GO_PKG_TARGETS
  # Build target for package and target OS/arch
  go-pkg-build/$1/$(call GO_PKG_NAME,$2):
	@echo "[$1] pkg:build: $(call GO_PKG_NAME,$2)"
	@GOOS=$(firstword $(subst /, ,$1)) GOARCH=$(lastword $(subst /, ,$1))  \
		$(GO_BIN) install $(GO_BUILD_FLAGS) $2

  .PHONY: go-pkg-build/$1/$(call GO_PKG_NAME,$2)

  # Clean target for package and target OS/arch
  go-pkg-clean/$1/$(call GO_PKG_NAME,$2):
	@echo "[$1] pkg:clean: $(call GO_PKG_NAME,$2)"
	@GOOS=$(firstword $(subst /, ,$1)) GOARCH=$(lastword $(subst /, ,$1)) \
		$(GO_BIN) clean $(GO_BUILD_FLAGS) $2

  .PHONY: go-pkg-clean/$1/$(call GO_PKG_NAME,$2)

  # Add default target for GO_HOSTOS/GO_HOSTARCH combination
  ifeq ($(1),$(GO_HOSTOS)/$(GO_HOSTARCH))
  go-pkg-build/$(call GO_PKG_NAME,$2): go-pkg-build/$1/$(call GO_PKG_NAME,$2)

  .PHONY: go-pkg-build/$(call GO_PKG_NAME,$2)

  go-pkg-clean/$(call GO_PKG_NAME,$2): go-pkg-clean/$1/$(call GO_PKG_NAME,$2)

  .PHONY: go-pkg-clean/$(call GO_PKG_NAME,$2)
  endif 
endef

# Use macro to generate targets
$(foreach osarch,$(GO_BUILD_OSARCHS),$(foreach pkg,$(GO_PACKAGES),$(eval $(call _CREATE_GO_PKG_TARGETS,$(osarch),$(pkg)))))

define _CREATE_GO_PKG_OSARCH_TARGETS
  go-pkg-build-all/$1: $(foreach pkg,$(GO_PACKAGES),go-pkg-build/$1/$(call GO_PKG_NAME,$(pkg)))

  .PHONY: go-pkg-build-all/$1

  go-pkg-clean-all/$1: $(foreach pkg,$(GO_PACKAGES),go-pkg-clean/$1/$(call GO_PKG_NAME,$(pkg)))

  .PHONY: go-pkg-clean-all/$1

  ifeq ($(1),$(GO_HOSTOS)/$(GO_HOSTARCH))
  go-pkg-build-all: go-pkg-build-all/$1

  go-pkg-clean-all: go-pkg-clean-all/$1

  .PHONY: go-pkg-build-all go-pkg-clean-all
  endif
endef

$(foreach osarch,$(GO_BUILD_OSARCHS), $(eval $(call _CREATE_GO_PKG_OSARCH_TARGETS,$(osarch))))

endif
