# Define the GO_ROOT_PACKAGE_NAME
GO_ROOT_PACKAGE_NAME=github.com/anexia-it/go-makefiles/examples/simplepkg

# Import features, as desired.
include ../../packages.mk
include ../../gofmt.mk
include ../../goimports.mk
include ../../test.mk

# Override .DEFAULT_GOAL
.DEFAULT_GOAL := build

# Configure build target
build: go-format-all go-pkg-build-all

# Configure format target
format: go-format-all

# Configure clean target
clean: go-pkg-clean-all

# Configure test target: run only the tests in our GO_ROOT_PACKAGE_NAME
test: go-pkg-test/$(GO_ROOT_PACKAGE_NAME)

all: build

.PHONY: all build format clean test
