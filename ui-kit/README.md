# Rookframe UI Kit

Unthemed Godot controls, composition and behavior. A core-only install uses
Godot defaults and includes no custom fonts, material assets or Theme resources.

## Agent entry points

Read [the design contract](docs/design-system/principles.md) before UI work.
Use [public components](docs/public-components.md), [native recipes](docs/native-controls-and-recipes.md)
and [action panels](docs/action-panel.md) for implementation.
`rookframe/ui/catalogue.json` indexes the public resources.

The [sibling showcase](../showcase/README.md) contains native examples and
integration checks. Optional appearance packages belong outside this package.

## Consume a revision

Run the installer from the repository root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project
```

Resources install under `res://rookframe/ui/`. The installer includes runtime
resources and legal notices, excluding tests and examples. See the
[workspace installation instructions](../README.md#install-in-a-consumer) for
optional appearance and [v2 migration steps](../docs/migration-to-v2.md) for
the breaking resource and property changes.

## Support and verification

Normal resources under `rookframe/ui/` are public; `_internal/` is unsupported.
Paths, UIDs, semantic Theme variations and documented behavior participate in the
kit's independent SemVer contract. [Compatibility](docs/compatibility.md) defines
the relationship to SDK Editions and Rookframe Versions.

Run the standalone component check from the repository root:

```sh
godot --headless --editor --path ui-kit --import --quit
godot --headless --path ui-kit --script res://tests/unthemed_components.gd
```

For cross-package suites, install the pinned development runner:

```sh
godot --headless --path ui-kit --script res://plug.gd install
```

The [showcase verification instructions](../showcase/README.md#verify-changes)
describe the integration runner and native inspection. Theme integration checks
never install resources into this owning package.

Rookframe-owned source/assets use [MIT](LICENSE); third-party resources retain
[their notices](THIRD_PARTY_NOTICES.md). Human discussion and review evidence
belong in the workspace's linked Linear document.
