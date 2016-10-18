# env.mk provides the environment configuration and tries to guess
# common variable values if unset.
#
#
# Required variables: GO_ROOT_PACKAGE_NAME
# Overridable variables: GOROOT, GOPATH, GO_BIN, GO_TARGET_OSARCHS
# Provides variables: GO_HOSTOS, GO_HOSTARCH

# Automatically detect GOROOT, depending on the location of the "go" binary
ifndef GOROOT
GO_BIN=$(which go)
ifeq ($(GO_BIN),)
$(error GOROOT is not set and 'go' was not found on PATH.)
endif # ifeq ($(GO_BIN),)
GOROOT=$(shell readlink -e $(shell dirname $(GO_BIN)))
$(info Set GOROOT to directory detected via location of 'go' binary)
endif # ifndef GOROOT

# Check if GOPATH is set
ifndef GOPATH
$(error GOPATH not set.)
endif # ifndef GOPATH

# Set GO_BIN variable pointing to the "go" binary
ifndef GO_BIN
GO_BIN=$(GOROOT)/bin/go
ifneq ($(shell test -x $(GO_BIN) && echo "ok"),ok)
$(error 'go' binary not executable at $(GO_BIN))
endif # ifneq ($(shell test -x $(GO_BIN) && echo "ok"),ok)
endif # ifndef GO_BIN

# Check if GO_ROOT_PACKAGE_NAME is set
ifndef GO_ROOT_PACKAGE_NAME
$(error GO_ROOT_PACKAGE_NAME not set)
endif # ifndef GO_ROOT_PACKAGE_NAME

# Set GO_HOSTARCH
ifndef GO_HOSTARCH
GO_HOSTARCH=$(shell $(GO_BIN) env GOHOSTARCH)
ifeq ($(GO_HOSTARCH),)
$(error Could not detect GOHOSTARCH.)
endif # ifeq ($(GO_HOSTARCH),)
endif # ifndef GO_HOSTARCH

# Set GO_HOSTOS
ifndef GO_HOSTOS
GO_HOSTOS=$(shell $(GO_BIN) env GOHOSTOS)
ifeq ($(GO_HOSTOS),)
$(error Could not detect GOHOSTOS.)
endif # ifeq ($(GO_HOSTOS),)
endif # ifndef GO_HOSTOS

# Set default GO_BUILD_OSARCHS
ifndef GO_BUILD_OSARCHS
GO_BUILD_OSARCHS=\
	linux/amd64 linux/386 \
	windows/amd64 windows/386 \
	darwin/amd64 darwin/386
endif # ifndef GO_BUILD_OSARCHS
