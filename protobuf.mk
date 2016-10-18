# protobuf.mk provides support for (re-)generating code from .proto
# files.
#
# Overridable variables: GO_PROTOC_FLAGS,GO_PROTOC_OUT

ifndef GO_PROTOC_OUT
$(error GO_PROTOC_OUT not set. (ie. plugins=grpc:.))
endif

# Set PROTOC by default
ifndef PROTOC
PROTOC=$(shell which protoc)
endif

ifeq ($(PROTOC),)
$(error PROTOC not set and 'protoc' not found on PATH.)
endif

ifndef _HAVE_PROTOBUF
_HAVE_PROTOBUF=1

PROTO_FILES=$(shell find . -name '*.proto' | grep -v './vendor/')
PROTO_GO_FILES=$(PROTO_FILES:%.proto=%.pb.go)

%.pb.go: %.proto
	@echo "proto: $< -> $@"
	@$(PROTOC) $< $(GO_PROTOC_FLAGS) --go_out=$(GO_PROTOC_OUT)


go-protobuf-build-all: $(PROTO_GO_FILES)
	@echo "Proto files are now up-to-date."

go-protobuf-clean-all:
	@rm -f $(PROTO_GO_FILES)

.PHONY: go-protobuf-build-all go-protobuf-clean-all

endif
