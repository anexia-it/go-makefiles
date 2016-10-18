# test.mk provides targets for running Go unit tests
#
# Overridable variables: GO_TEST_PACKAGES, GO_TEST_FLAGS, GO_BENCHMARK_FLAGS,
#                        GO_TEST_COVERAGE_HTML, GO_TEST_COVERAGE_TMPDIR,
#                        GO_TEST_COVERAGE_HTML_PATH

# Include env.mk - this provides us with $(GO_BIN)
include $(dir $(lastword $(MAKEFILE_LIST)))env.mk

# Include packages.mk - this provides us with GO_PACKAGES
# and the GO_PKG_NAME macro.
include $(dir $(lastword $(MAKEFILE_LIST)))packages.mk

ifndef _HAVE_TEST_MK
_HAVE_TEST_MK=1
# Set GO_TEST_PACKAGES to GO_PACKAGES by default
ifndef GO_TEST_PACKAGES
GO_TEST_PACKAGES=$(GO_PACKAGES)
endif # ifndef GO_TEST_PACKAGES

# If the test coverage temporary directory location is not set,
# set it to ./coverage.tmp
ifndef GO_TEST_COVERAGE_TMPDIR
GO_TEST_COVERAGE_TMPDIR=./coverage.tmp
endif # ifndef GO_TEST_COVERAGE_TMPDIR

# If the path to the coverage.html file is not set, set it to ./coverage.html
ifndef GO_TEST_COVERAGE_HTML_PATH
GO_TEST_COVERAGE_HTML_PATH=./coverage.html
endif # ifndef GO_TEST_COVERAGE_HTML_PATH

# If GO_TEST_COVERAGE_HTML is undefined, disable test coverage generation
ifndef GO_TEST_COVERAGE_HTML
GO_TEST_COVERAGE_HTML=0
endif # ifndef GO_TEST_COVERAGE_HTML

# Set GO_TEST_FLAGS to -v by default
ifndef GO_TEST_FLAGS
GO_TEST_FLAGS=-v
endif # ifndef GO_TEST_FLAGS

ifndef GO_BENCHMARK_FLAGS
GO_BENCHMARK_FLAGS=-v -run=invalid
endif # ifndef GO_BENCHMARK_FLAGS

ifeq ($(GO_TEST_PACKAGES),)
$(error No Go test packages found.
endif # ifeq ($(GO_TEST_PACKAGES),)

define _CREATE_GO_TEST_TARGETS
  go-pkg-test/$(call GO_PKG_NAME,$1):
	@echo "pkg:test: $(call GO_PKG_NAME,$1)"
	@$(GO_BIN) test $(GO_TEST_FLAGS) $1
  .PHONY: go-pkg-test/$(call GO_PKG_NAME,$1)

  go-pkg-benchmark/$(call GO_PKG_NAME,$1):
	@echo "pkg:benchmark: $(call GO_PKG_NAME,$1)"
	@$(GO_BIN) test $(GO_BENCHMARK_FLAGS) $1
  .PHONY: go-pkg-benchmark/$(call GO_PKG_NAME,$1)

  go-pkg-coverage/$(call GO_PKG_NAME,$1):
	@mkdir -p $(GO_TEST_COVERAGE_TMPDIR)
	@echo "pkg:coverage: $(call GO_PKG_NAME,$1)"
	@$(GO_BIN) test -cover -coverprofile \
		./$(GO_TEST_COVERAGE_TMPDIR)/$(subst \
			/,_,$(call GO_PKG_NAME,$1)).coverage \
		$1
  .PHONY: go-pkg-coverage/($(call GO_PKG_NAME,$1)
endef

# Use macro to generate targets
$(foreach pkg,$(GO_TEST_PACKAGES),$(eval $(call _CREATE_GO_TEST_TARGETS,$(pkg))))

go-pkg-test-all: $(foreach pkg,$(GO_TEST_PACKAGES),go-pkg-test/$(call GO_PKG_NAME,$(pkg)))

# Provide the go-packages-benchmark target
go-pkg-benchmark-all: $(foreach pkg,$(GO_TEST_PACKAGES),go-pkg-benchmark/$(call GO_PKG_NAME,$(pkg)))

go-pkg-coverage-all: $(foreach pkg,$(GO_TEST_PACKAGES),go-pkg-coverage/$(call GO_PKG_NAME,$(pkg)))
	$(info Coverage results:)
	@mkdir -p $(GO_TEST_COVERAGE_TMPDIR)
	@echo "mode: set" > $(GO_TEST_COVERAGE_TMPDIR)/combined
	@sed -e '/mode:.*/d' $(GO_TEST_COVERAGE_TMPDIR)/*.coverage \
		>> $(GO_TEST_COVERAGE_TMPDIR)/combined
ifeq ($(GO_TEST_COVERAGE_HTML),1)
	@$(GO_BIN) tool cover -html $(GO_TEST_COVERAGE_TMPDIR)/combined \
		-o $(GO_TEST_COVERAGE_HTML_PATH)
endif # ifeq ($(GO_TEST_COVERAGE_HTML),1)
	@$(GO_BIN) tool cover -func=$(GO_TEST_COVERAGE_TMPDIR)/combined | \
		grep 'total' | \
		awk '{print "Coverage: " $$3 " of all functions"; }'

.PHONY: go-pkg-test-all go-pkg-benchmark-all go-pkg-coverage-all

endif # ifndef _HAVE_TEST_MK
