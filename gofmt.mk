# format.mk provides the go-format target.
# This target formats the passed Go files
#
# Overridable variables: GOFMT_FLAGS, GOFMT_BIN

# Include env.mk - this provides us with $(GO_BIN)
include $(dir $(lastword $(MAKEFILE_LIST)))/env.mk

# Include go_files.mk - this provides us with $(GO_FILES)
include $(dir $(lastword $(MAKEFILE_LIST)))/go_files.mk

# Define GOFMT_FLAGS if undefined
ifndef GOFMT_FLAGS
GOFMT_FLAGS=
endif # ifndef GOFMT_FLAGS

# Define GOFMT_BIN if undefined
ifndef GOFMT_BIN
GOFMT_BIN=$(GO_BIN) fmt
endif # ifndef GOFMT_BIN

# Ensure the rules and targets below are generated only once
ifndef _HAVE_GO_FORMAT
_HAVE_GO_FORMAT=1

# _CREATE_GO_FMT_TARGET generates the Makefile target for a given
# .go file
define _CREATE_GO_FMT_TARGET
  go-format/$1:
	@echo "file:fmt: $(call GO_FILE_NAME,$1)"
	@$(GOFMT_BIN) $(GOFMT_FLAGS) $1
  .PHONY: go-format/$1
endef

# Use macro to generate targets
$(foreach file,$(GO_FILES),$(eval $(call _CREATE_GO_FMT_TARGET,$(file))))

# Define the go-format-all target, which calls all generated go-fmt/* targets
go-format-all: $(foreach file,$(GO_FILES),go-format/$(file))
.PHONY: go-format-all

endif # ifndef _HAVE_GO_FORMAT
