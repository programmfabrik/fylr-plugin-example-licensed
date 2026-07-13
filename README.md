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
make            # -> build/example-licensed_sealed.zip (a valid zip)
```

The sealed plugin is an ordinary zip whose single entry is the encrypted plugin:

```
build/example-licensed_sealed.zip
└── fylr-sealed-plugin.enc
```

## Publish to GitHub Pages

Publishing a GitHub **release** runs the [workflow](.github/workflows/release.yml):
it builds the plugin, seals it, attaches the sealed zip to the release, and
publishes it to **GitHub Pages** under an unguessable filename — the same delivery
mechanism the other fylr plugins use (e.g. `fylr-plugin-ai-metadata`):

```
https://programmfabrik.github.io/fylr-plugin-example-licensed/fylr-plugin-example-licensed-a5c6d4ba-9284-4b36-acf2-42ddbfa31edf-latest.zip
```

The UUID in the filename (`ZIP_HASH` in the workflow) is the "hash": for a
*private* licensed-plugin repo, that Pages URL is the only handle to the artifact.
Sealing adds a second layer — a leaked URL still yields nothing without fylr's key.

One-time setup: in the repo **Settings → Pages**, set the source to **GitHub
Actions**.

## Install and test in fylr

An administrator installs the plugin from that Pages URL — either directly
(`PUT /plugin/manage` with `type: url`) or by offering it from a
`plugin.shop.sources` entry in `fylr.yml`. fylr fetches the zip, decrypts the
sealed entry with its key, and installs the plugin.

Because this repo seals to the **dev/CI** key, the published plugin installs and
runs only on a fylr built with `-tags licensetest`; a normal release build rejects
it — the licensed-delivery guarantee in miniature. A real paid plugin seals to the
production key and installs on the customers whose license carries it.
