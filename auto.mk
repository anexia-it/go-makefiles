# auto.mk provides a simple starting that automatically generates
# the top-level Makefile targets.
# Tge AUTO_* variables may be set to 1 to enable a specific behavior
#
# Required variables: GO_ROOT_PACKAGE_NAME
# Optional variables: AUTO_ENABLE_GOFMT, AUTO_ENABLE_GOIMPORTS, GO_BINARIES
#                     AUTO_ENABLE_TEST, AUTO_ENABLE_BENCHMARK,
#                     AUTO_ENABLE_GENERATE

# GOOS/GOARCH independent build targets
_AUTO_BUILD_TARGETS_INDEP=
# GOOS/GOARCH indepenent clean targets
_AUTO_CLEAN_TARGETS_INDEP=
# GOOS/GOARCH dependent build targets
_AUTO_BUILD_TARGETS_DEP=go-pkg-build-all
# GOOS/GOARCH dependent clean targets
_AUTO_CLEAN_TARGETS_DEP=go-pkg-clean-all
# Build targets that may not run during cross-compilation (late)
_AUTO_BUILD_TARGETS_NOCROSS_LATE=
# Clean targets that may not run during cross-compilation (late)
_AUTO_CLEAN_TARGETS_NOCROSS_LATE=

ifndef GO_ROOT_PACKAGE_NAME
$(error GO_ROOT_PACKAGE_NAME not set.)
endif # ifndef GO_ROOT_PACKAGE_NAME

include $(dir $(lastword $(MAKEFILE_LIST)))env.mk

# Check if binary support should be generated
ifeq ($(AUTO_ENABLE_BINARIES),1)
include $(dir $(lastword $(MAKEFILE_LIST)))binaries.mk
_AUTO_BUILD_TARGETS_DEP+=go-bin-build-all
_AUTO_CLEAN_TARGETS_DEP+=go-bin-clean-all
endif # ifeq ($(AUTO_ENABLE_BINARIES),1)

# It is important to include packages.mk only AFTER checking for binaries
include $(dir $(lastword $(MAKEFILE_LIST)))packages.mk

# Check if gofmt should be enabled
ifeq ($(AUTO_ENABLE_GOFMT),1)
include $(dir $(lastword $(MAKEFILE_LIST)))gofmt.mk
_AUTO_BUILD_TARGETS_INDEP+=go-format-all
endif # ifeq ($(AUTO_ENABLE_GOFMT),1)

# Check if goimports should be enabled
ifeq ($(AUTO_ENABLE_GOIMPORTS),1)
include $(dir $(lastword $(MAKEFILE_LIST)))goimports.mk
_AUTO_BUILD_TARGETS_INDEP+=go-imports-all
endif # ifeq ($(AUTO_ENABLE_GOIMPORTS),1)

# Check if tests should be enabled
ifeq ($(AUTO_ENABLE_TEST),1)
include $(dir $(lastword $(MAKEFILE_LIST)))test.mk
_AUTO_BUILD_TARGETS_NOCROSS_LATE+=go-pkg-test-all

# Add the test target
test: go-pkg-test-all

# Add the coverage target
coverage: go-pkg-coverage-all

.PHONY: test coverage
endif # ifeq ($(AUTO_ENABLE_TEST),1)

# Check if benchmarks should be enabled
ifeq ($(AUTO_ENABLE_BENCHMARK),1)
include $(dir $(lastword $(MAKEFILE_LIST)))test.mk
_AUTO_BUILD_TARGETS_NOCROSS_LATE+=go-pkg-benchmark-all

# Add the benchmark target
benchmark: go-pkg-benchmark-all

.PHONY: benchmark
endif # ifeq ($(AUTO_ENABLE_BENCHMARK),1)

ifeq ($(AUTO_ENABLE_GENERATE),1)
include $(dir $(lastword $(MAKEFILE_LIST)))generate.mk
_AUTO_BUILD_TARGETS_INDEP+=go-generate-all

# Add the generate target
generate: go-generate-all

.PHONY: generate
endif # ifeq ($(AUTO_ENABLE_GENERATE),1)


define _CREATE_AUTO_OSARCH_TARGETS
  build/$1: $(_AUTO_BUILD_TARGETS_INDEP) $(subst build-all,build-all/$1,$(_AUTO_BUILD_TARGETS_DEP))

  clean/$1: $(_AUTO_CLEAN_TARGETS_INDEP) $(subst clean-all,clean-all/$1,$(_AUTO_CLEAN_TARGETS_DEP))

  .PHONY: build/$1 clean/$1
endef

$(foreach osarch,$(GO_BUILD_OSARCHS),$(eval $(call _CREATE_AUTO_OSARCH_TARGETS,$(osarch))))

# Construct the build target
build: build/$(GO_HOSTOS)/$(GO_HOSTARCH) $(_AUTO_BUILD_TARGETS_NOCROSS_LATE)

# Construct the clean target
clean: clean/$(GO_HOSTOS)/$(GO_HOSTARCH) $(_AUTO_CLEAN_TARGETS_NOCROSS_LATE)

all: build

.PHONY: all build clean

# Override .DEFAULT_GOAL
.DEFAULT_GOAL := build
