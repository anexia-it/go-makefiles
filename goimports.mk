# goimports.mk provides the go-imports target
# This target runs goimports on the given
#
# Overridable variables: GOIMPORTS_FLAGS, GOIMPORTS_BIN

# Include env.mk - this provides us with $(GO_BIN)
include $(dir $(lastword $(MAKEFILE_LIST)))env.mk

# Include go_files.mk - this provides us with $(GO_FILES)
include $(dir $(lastword $(MAKEFILE_LIST)))go_files.mk

# Define GOIMPORTS_FLAGS if undefined
ifndef GOIMPORTS_FLAGS
GOIMPORTS_FLAGS=-e=true -w=true
endif # ifndef GOIMPORTS_FLAGS

# Define GOIMPORTS_BIN if undefined
ifndef GOIMPORTS_BIN
# Try looking up goimports on our PATH
GOIMPORTS_BIN=$(shell which goimports)
ifeq ($(GOIMPORTS_BIN),)
$(error GOIMPORTS_BIN is not set and 'goimports' was not found on PATH.)
endif # ifeq ($(GOIMPORTS_BIN),)
endif # ifndef GOIMPORTS_BIN

# Ensure the rules and targets below are generated only once
ifndef _HAVE_GO_IMPORTS
_HAVE_GO_IMPORTS=1

# _CREATE_GO_IMPORTS_TARGET generates the Makefile target for a given
# .go file
define _CREATE_GO_IMPORTS_TARGET
  go-imports/$1: 
	@echo "file:imports: $(call GO_FILE_NAME,$1)"
	@$(GOIMPORTS_BIN) $(GOIMPORTS_FLAGS) $1
  .PHONY: go-imports/$1
endef

# Use macro to generate targets
$(foreach file,$(GO_FILES),$(eval $(call _CREATE_GO_IMPORTS_TARGET,$(file))))

# Define the go-imports-all target, which calls all generated go-imports/*
# targets
go-imports-all: $(foreach file,$(GO_FILES),go-imports/$(file))
.PHONY: go-imports-all

endif # ifndef _HAVE_GO_IMPORTS
