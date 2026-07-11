# fylr-plugin-example-licensed

A minimal **example of a licensed fylr plugin**: a plugin that is released
*sealed* so its code can only be opened and run by a fylr server holding the
matching key. It exists to demonstrate — end to end, in a public repo, with no
secrets — how a paid plugin is built, sealed and delivered through the fylr
Plugin Shop.

The plugin itself is deliberately trivial (`example-licensed/`: a manifest and a
served web file). The interesting part is the release pipeline.

## How it's sealed

The [release workflow](.github/workflows/release.yml) builds `example-licensed.zip`
and seals it with [`fylr-encrypt-plugin`](https://github.com/programmfabrik/fylr-encrypt-plugin):

```sh
go run github.com/programmfabrik/fylr-encrypt-plugin@latest \
    -in example-licensed.zip -out example-licensed_sealed.zip
```

Sealing uses a **public** key only, so the workflow needs no secret. With the
default key, the plugin is sealed to fylr's **dev/CI** key — so
`example-licensed_sealed.zip` opens **only** on a fylr built with
`-tags licensetest`. That is exactly what makes this safe to publish: the sealed
code is inert on a normal release build.

A real paid plugin is identical except it passes `-pubkey` with the production
public key (or a shop source's own key) — still no secret in the repo.

## Build locally

```sh
make            # -> example-licensed_sealed.zip (a valid zip)
```

`example-licensed_sealed.zip` is an ordinary zip whose single entry is the sealed
plugin:

```
example-licensed_sealed.zip
└── fylr-sealed-plugin.enc
```

## Install in fylr

A fylr administrator installs it through the Plugin Shop from a source that offers
this plugin's sealed release URL (in `fylr.yml`, `plugin.shop.sources`). fylr
fetches the zip, decrypts the sealed entry with its key, and installs the plugin.
On a `-tags licensetest` fylr the default-sealed release installs and runs; on a
normal build it is rejected — the licensed-delivery guarantee in miniature.

## Release

Push a `vX.Y.Z` tag; the workflow builds, seals, and attaches
`example-licensed_sealed.zip` to the GitHub release. (Requires
`fylr-encrypt-plugin` to be published.)
