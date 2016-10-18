# binaries.mk provides Makefile targets for building Go binaries
#
# Overridable variables: GO_BINARIES, GO_BIN_TARGET, GO_BIN_SUFFIX

# Do not run if GO_BINARIES has already been set.
ifndef GO_BINARIES
GO_BINARIES=$(shell go list -f '{{.Name}}:{{.ImportPath}}' ./... | \
	grep -v '/vendor/' | \
	egrep '^main:' | \
	sed -e 's|^main:||g' -e 's|$(GO_ROOT_PACKAGE_NAME)|.|g')
endif # ifndef GO_BINARIES

# Check if GO_BIN_TARGET is set.
ifndef GO_BIN_TARGET
GO_BIN_TARGET=./bin
endif # ifndef GO_BIN_TARGET

define _CREATE_GO_BIN_TARGETS
  go-bin-build/$1/$2:
	@echo "[$1] bin:build: $2 -> $(GO_BIN_TARGET)/$1/$(notdir $2)"
	@mkdir -p $(GO_BIN_TARGET)/$1
	@GOOS=$(firstword $(subst /, ,$1)) GOARCH=$(lastword $(subst /, ,$1)) \
		$(GO_BIN) build -o \
			$(GO_BIN_TARGET)/$1/$(notdir $2) ./$2

  go-bin-clean/$1/$2:
	@echo "[$1] bin:clean: $2"
	@rm -f $(GO_BIN_TARGET)/$1/$(notdir $2)

  .PHONY: go-bin-build/$1/$2 go-bin-clean/$1/$2

  ifeq ($1,$(GO_HOSTOS)/$(GO_HOSTARCH))
  go-bin-build/$2: go-bin-build/$1/$2
	@echo "[$1] bin:symlink: $(GO_BIN_TARGET)/$(notdir $2)"
	@rm -f $(GO_BIN_TARGET)/$(notdir $2)
	@ln -s $1/$(notdir $2) \
		$(GO_BIN_TARGET)/$(notdir $2)
  go-bin-clean/$2: go-bin-clean/$1/$2
	@rm -f $(GO_BIN_TARGET)/$(notdir $2)

  .PHONY: go-bin-build/$2 go-bin-clean/$2
  endif
endef

define _CREATE_GO_BIN_OSARCH_TARGETS
  go-bin-build-all/$1: $(foreach bin,$(GO_BINARIES),go-bin-build/$1/$(bin))
  go-bin-clean-all/$1: $(foreach bin,$(GO_BINARIES),go-bin-clean/$1/$(bin))
  .PHONY: go-bin-build-all/$1 go-bin-build-all/$1

  ifeq ($1,$(GO_HOSTOS)/$(GO_HOSTARCH))
  go-bin-build-all: go-bin-build-all/$1 $(foreach bin,$(GO_BINARIES),go-bin-build/$(bin))
  go-bin-clean-all: go-bin-clean-all/$1 $(foreach bin,$(GO_BINARIES),go-bin-clean/$(bin))
  .PHONY: go-bin-build-all go-bin-clean-all
  endif
endef

# Generate targets only if at least one binary was found
ifneq ($(GO_BINARIES),)
ifndef _HAVE_GO_BINARIES
_HAVE_GO_BINARIES=1
# Use macro to generate targets
$(foreach osarch,$(GO_BUILD_OSARCHS), \
	$(foreach bin,$(GO_BINARIES),\
		$(eval $(call _CREATE_GO_BIN_TARGETS,$(osarch),$(bin))) \
	) \
)
$(foreach osarch,$(GO_BUILD_OSARCHS), \
	$(eval $(call _CREATE_GO_BIN_OSARCH_TARGETS,$(osarch))) \
)
endif # ifndef _HAVE_GO_BINARIES

endif # ifneq ($(GO_BINARIES),)
