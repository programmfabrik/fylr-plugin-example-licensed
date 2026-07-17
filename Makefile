# fylr plugins are built by fylr-build-plugin, the build driver that knows how
# a fylr plugin is put together (compile, assemble build/, zip, seal, loca).
# This Makefile is a thin shim for muscle memory — all logic lives in the
# tool. @latest always resolves the tool's newest release; an incompatible
# tool change would come as a new major version (import path .../v2), which is
# the only event that changes this line.
#
# Tools needed:
#   go       runs fylr-build-plugin — https://go.dev/dl/
FYLR_BUILD_PLUGIN ?= go run github.com/programmfabrik/fylr-build-plugin@latest

# The tool itself reads NO environment variables — everything is passed as
# flags. The release workflow's RELEASE_TAG env is translated into flags
# right here.
RELEASE_FLAGS = $(if $(RELEASE_TAG),-release "$(RELEASE_TAG)")

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: seal ## build + seal (the artifact this repo exists for)

build: ## build the plugin into build/<name>/
	$(FYLR_BUILD_PLUGIN) build $(RELEASE_FLAGS)

zip: ## build the plaintext plugin zip
	$(FYLR_BUILD_PLUGIN) zip $(RELEASE_FLAGS)

seal: ## build + seal the plugin zip (fylr dev/CI key unless -pubkey is passed to the tool)
	$(FYLR_BUILD_PLUGIN) seal $(RELEASE_FLAGS)

check: ## validate the build tree against the manifest
	$(FYLR_BUILD_PLUGIN) check

clean: ## clean build files
	$(FYLR_BUILD_PLUGIN) clean

.PHONY: help all build zip seal check clean
