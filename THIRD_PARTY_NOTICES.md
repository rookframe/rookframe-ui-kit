# Third-party notices

## Tabler Icons

The public semantic icon registry vendors a curated 65-icon subset of
[Tabler Icons](https://tabler.io/icons), version 3.46.0, from commit
`8ac7d81b72ece11072ef25ea9fd92e80c6f3c9fc`.

- License: MIT
- License text: `rookframe/ui/icons/LICENSE`
- Semantic-to-upstream mapping: `rookframe/ui/icons/manifest.json`

The semantic filename is the Rookframe public identity. The upstream filename
recorded in the manifest is provenance, not consumer API. Vendored SVGs change
only `currentColor` to a white stroke so Godot can tint the unchanged geometry
through `CanvasItem.modulate`.

## Exo 2

`rookframe/ui/assets/fonts/Exo2-VariableFont_wght.ttf` is Copyright 2013 The
Exo 2 Project Authors and is redistributed under the SIL Open Font License
1.1 in `rookframe/ui/assets/fonts/LICENSE-EXO-2.txt`.

SHA-256:
`205a448676a2586f9c57c25f3d5c58ca8db7e6cf5edf7506783a010c6fe2bfb5`

## Inter

`rookframe/ui/assets/fonts/Inter-VariableFont_opsz,wght.ttf` is Copyright 2020
The Inter Project Authors and is redistributed under the SIL Open Font License
1.1 in `rookframe/ui/assets/fonts/LICENSE-INTER.txt`.

SHA-256:
`29160a80ff49ddcab2c97711247e08b1fab27a484a329ce8b813d820dc559031`

## Rookframe frame assets

The nine-slice assets under `rookframe/ui/assets/frames/` are deterministic
Rookframe-owned renderings of the checked-in Rookframe frame geometry. They are
distributed under this repository's MIT License.

No legacy shell atlas, example portrait, Font Awesome artwork, or asset with
unclear provenance is included in the public foundation.

## gd-plug development consumer

The clean consumer example vendors gd-plug at commit
`209276d1f00d14b49b74403d9839f29598e9a8eb` under the MIT License in
`examples/exact-commit-consumer/addons/gd-plug/LICENSE`. gd-plug is development
material outside `rookframe/ui` and is not installed with the UI Kit. The
consumer declaration adds a local exit-status override without modifying the
vendored gd-plug runtime.

## Game-icons.net

Seven selected illustrated RPG pictograms by Lorc and Delapouite are supplied
as unmodified white-on-transparent SVGs under **CC BY 3.0**, separately from
the Tabler general-action registry. See the installed
[per-artwork attribution](rookframe/ui/icons/game-icons/ATTRIBUTION.md) and
`domainPictograms` in `rookframe/ui/icons/manifest.json` for source links,
authors, download URLs and content hashes. Preserve these credits in
distributions; identify changes to adapted artwork.

## Noto Serif regional companions

Full Noto Serif JP, KR, SC and TC variable fonts from `google/fonts` revision
`7085eb89a950e85db5b166b7a58d414544b4140c` are installed under
`rookframe/ui/assets/fonts/noto-serif-{jp,kr,sc,tc}/`. Each directory retains
its unmodified OFL.txt and METADATA.pb, including upstream author and source
revision. They are redistributed under SIL Open Font License 1.1. Native font
imports set language priority; source font bytes are unchanged.
