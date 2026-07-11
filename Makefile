# Build the plugin zip and seal it for the fylr Plugin Shop.
#
#   make          -> example-licensed_sealed.zip
#
# The sealed plugin is a valid zip whose single entry is the plugin sealed to
# fylr's dev/CI key, so it opens only on a fylr built with -tags licensetest. A
# real paid plugin passes -pubkey with the production (or a shop source's) key.
#
# The zip's top-level directory must match the plugin name (example-licensed).
NAME = example-licensed

all: sealed

zip:
	rm -f $(NAME).zip
	zip -r $(NAME).zip $(NAME)

sealed: zip
	go run github.com/programmfabrik/fylr-encrypt-plugin@latest \
		-in $(NAME).zip -out $(NAME)_sealed.zip

clean:
	rm -f $(NAME).zip $(NAME)_sealed.zip

.PHONY: all zip sealed clean
