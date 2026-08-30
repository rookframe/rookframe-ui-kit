# Rookframe UI Kit

The canonical, public source of Rookframe's native-first Godot UI Kit. It
provides one shared Theme, semantic assets, and—where Godot does not already
own the behavior—small reusable scene relationships for Rookframe Package
Publishers and Rookframe applications.

This repository is not generated from `rookframe-godot`. Consumers materialize
the exact source they select at the one canonical runtime root:
`res://rookframe/ui/`.

## Current foundation

The RFG-160 foundation includes:

- the complete classified coverage inventory from the old Bevy Rookframe and
  the current Godot implementation;
- semantic colors, type, spacing, geometry, focus, surfaces, and frame assets;
- Inter and Exo 2 with their SIL Open Font License texts;
- the 62-role semantic Tabler icon registry; and
- representative native Godot Controls in a development catalogue.

The inventory deliberately assigns the reusable relationship work to RFG-161.
Application screens, workflows, domain state, host orchestration, redundant
native wrappers, and a public C# widget hierarchy remain outside this kit.

See [the coverage inventory](docs/design-system-coverage.md),
[the public foundation reference](docs/public-foundation.md), and
[third-party notices](THIRD_PARTY_NOTICES.md).

## Exact-commit installation

Commit `plug.gd` and gd-plug's runtime to the consuming Godot project, then
declare the UI Kit with a full 40-character commit:

```gdscript
extends "res://addons/gd-plug/plug.gd"


func _plugging() -> void:
	plug("rookframe/rookframe-ui-kit", {
		"commit": "c7e3c9277436c062dfad29d533fce16ec59c7978",
		"include": ["rookframe/ui"],
	})
```

Run gd-plug with Godot 4:

```sh
godot --headless -s plug.gd install
```

The copied Theme then exists at
`res://rookframe/ui/theme/rookframe_theme.tres`. Assign it to a scene root or
set it as the project Theme:

```ini
[gui]

theme/custom="res://rookframe/ui/theme/rookframe_theme.tres"
```

The checked-in [exact-commit consumer](examples/exact-commit-consumer) is the
normal-Godot proof of this seam. The repository's
[foundation catalogue](examples/foundation-catalogue) remains outside the
installed runtime subtree.

## Public boundary

Every normal resource beneath `rookframe/ui/` is public and supported. Its
path, UID, semantic Theme variation name, and documented purpose participate in
the UI Kit's independent SemVer contract. Only `rookframe/ui/_internal/` is
unsupported. Examples, repository tools, and development material live outside
the installed subtree.

The UI Kit does not participate in SDK Editions. A Package records its exact
authoring UI Kit commit as provenance, excludes the materialized kit from its
artifact, and declares compatible Rookframe Versions for runtime compatibility.
Direct use of Godot APIs remains outside Rookframe's compatibility guarantee.

Stable `v1.0.0` has not been published. Release timing remains an explicit
owner action.

## Development catalogue

Open this repository as a Godot 4.7 project or run it with the pinned toolchain:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --path .
```

The catalogue is manual visual and interaction evidence, not an automated
validation suite or release gate.

## License

Rookframe-owned source and assets use the [MIT License](LICENSE). Third-party
fonts and icons retain their compatible licenses and attribution in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
