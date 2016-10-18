# go_files.mk provides the list of Go source code files

# Conditionally define GO_FILES
ifndef GO_FILES
GO_FILES=$(shell find . -name '*.go' | egrep -v '^./vendor/')
# Check if any source files were found
ifeq ($(GO_FILES),)
$(error No Go source files found.)
endif # ifeq ($(GO_FILES),)

# GO_FILE_NAME takes a relative file name and converts it into an
# absolute go package name with the file name appended
define GO_FILE_NAME
$(subst ./,$(GO_ROOT_PACKAGE_NAME)/,$1)
endef

endif # ifndef GO_FILES


