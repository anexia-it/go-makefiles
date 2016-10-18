# generate.mk provides support for go generate.
#
# Overridable variables: GO_GENERATE_FLAGS

# Include env.mk - this provides us with $(GO_BIN)
include $(dir $(lastword $(MAKEFILE_LIST)))/env.mk
# Include go_files.mk - this provides us with $(GO_FILES)
include $(dir $(lastword $(MAKEFILE_LIST)))/go_files.mk

# Conditionally add flags
ifndef _HAVE_GENERATE
_HAVE_GENERATE=1

# Find files that include //go:generate comments
_GENERATE_FILES=$(foreach file,$(GO_FILES),\
	$(shell egrep -q '//go:generate' $(file) && echo $(file)))

define _CREATE_GO_GENERATE_TARGET
  go-generate/$1:
	@echo "file:generate: $(call GO_FILE_NAME,$1)"
	@$(GO_BIN) generate $(GO_GENERATE_FLAGS) $1
  .PHONY: go-generate/$1
endef

# Use macro to generate targets
ifneq ($(_GENERATE_FILES),)
$(foreach file,$(_GENERATE_FILES),$(eval $(call _CREATE_GO_GENERATE_TARGET,$(file))))
endif # ifneq ($(_GENERATE_FILES),)

go-generate-all: $(foreach file,$(_GENERATE_FILES),go-generate/$(file))
.PHONY: go-generate-all

endif # ifndef _HAVE_GENERATE
