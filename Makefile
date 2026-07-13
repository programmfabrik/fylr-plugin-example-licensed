# Build the plugin and seal it with fylr-encrypt-plugin, producing the artifact
# the release workflow publishes to GitHub Pages.
#
#   make          -> build/example-licensed_sealed.zip
#
# The sealed plugin is a valid zip whose single entry is the plugin sealed to
# fylr's dev/CI key, so it opens only on a fylr built with -tags licensetest. A
# real paid plugin passes -pubkey with the production (or a shop source's) key.
#
# The zip's top-level directory must match the plugin name (example-licensed).
NAME = example-licensed
BUILD = build

all: sealed

zip: ## build the plaintext plugin zip into build/
	rm -rf $(BUILD)
	mkdir -p $(BUILD)
	zip -r $(BUILD)/$(NAME).zip $(NAME)

sealed: zip ## seal the plugin zip for the fylr Plugin Shop
	go run github.com/programmfabrik/fylr-encrypt-plugin@latest \
		-in $(BUILD)/$(NAME).zip -out $(BUILD)/$(NAME)_sealed.zip

clean:
	rm -rf $(BUILD)

.PHONY: all zip sealed clean
