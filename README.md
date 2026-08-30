# Rookframe UI Kit

The canonical, public source of Rookframe's native-first Godot UI Kit. It
provides one shared Theme, semantic assets, and—where Godot does not already
own the behavior—small reusable scene relationships for Rookframe Package
Publishers and Rookframe applications.

This repository is not generated from `rookframe-godot`. Consumers materialize
the exact source they select at the one canonical runtime root:
`res://rookframe/ui/`.

## Native-first public kit

The current pre-release candidate includes:

- one shared Theme with complete coverage for the native Controls in the
  reviewed design-system inventory;
- semantic colors, type, spacing, geometry, focus, surfaces, frames, and a
  62-role icon registry;
- small editor-authored public scenes only for reusable relationships Godot
  does not provide as a built-in node;
- responsive layout, accessible forms and search, feedback, Managed Surface,
  and structured-data contracts; and
- a complete manual visual and interaction catalogue.

Application screens, workflows, domain state, host orchestration, redundant
native wrappers, and a public C# widget hierarchy remain outside this kit.

See [the coverage inventory](docs/design-system-coverage.md),
[the RFG-161 completion map](docs/rfg-161-coverage.md),
[the public component reference](docs/public-components.md),
[native recipes](docs/native-controls-and-recipes.md),
[accessibility and input](docs/accessibility-and-input.md),
[the public foundation reference](docs/public-foundation.md), and
[third-party notices](THIRD_PARTY_NOTICES.md).

## Exact-commit installation

Commit `plug.gd` and gd-plug's runtime to the consuming Godot project, then
declare the UI Kit with a full 40-character commit:

```gdscript
extends "res://addons/gd-plug/plug.gd"


func _plugging() -> void:
	plug("rookframe/rookframe-ui-kit", {
		"commit": "5f4ccbfaff195c59f8385582ca57c8020ea77164",
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
normal-Godot proof of this seam. It pins the completed component implementation
commit and instances a public Search Field directly from the materialized
canonical path. Repository catalogues remain outside the installed runtime
subtree.

## Public boundary

Every normal resource beneath `rookframe/ui/` is public and supported. Its
path, UID, semantic Theme variation name, and documented purpose participate in
the UI Kit's independent SemVer contract. Only `rookframe/ui/_internal/` is
unsupported. Examples, repository tools, and development material live outside
the installed subtree. `rookframe/ui/catalogue.json` is the machine-readable
index of public component contracts.

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

The project opens the complete catalogue at
`examples/catalogue/visual_catalogue.tscn`. Its Native, Forms, Layout,
Feedback, Data, Icons, and Managed tabs are manual visual and interaction
evidence, not an automated validation suite or release gate.

## License

Rookframe-owned source and assets use the [MIT License](LICENSE). Third-party
fonts and icons retain their compatible licenses and attribution in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
