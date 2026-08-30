# Third-party notices

## Tabler Icons

The public semantic icon registry vendors a curated 62-icon subset of
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

No legacy shell atlas, example portrait, Game-icons.net domain pictogram, Font
Awesome artwork, or asset with unclear provenance is included in the public
foundation.

## gd-plug development consumer

The clean consumer example vendors gd-plug at commit
`209276d1f00d14b49b74403d9839f29598e9a8eb` under the MIT License in
`examples/exact-commit-consumer/addons/gd-plug/LICENSE`. gd-plug is development
material outside `rookframe/ui` and is not installed with the UI Kit. The
consumer declaration adds a local exit-status override without modifying the
vendored gd-plug runtime.
