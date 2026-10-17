# Rookframe UI workspace

The UI Kit supplies unthemed Godot components. Silkbound Ledger, Fantasy and
Cyberpunk are optional appearance packages. The component library uses core
resources with stock Godot styling; separate examples exercise optional themes.

| Package | Contents |
| --- | --- |
| [ui-kit](ui-kit/README.md) | Unthemed controls, composition, theme compiler and component contracts |
| [showcase](showcase/README.md) | Native examples and integration checks |
| [themes/silkbound-ledger](themes/silkbound-ledger/README.md) | Silkbound materials, fonts, inherited scenes and presentation scripts |
| [themes/fantasy](themes/fantasy/README.md) | Fantasy mappings, materials and artwork |
| [themes/cyberpunk](themes/cyberpunk/README.md) | Cyberpunk mappings, materials and artwork |
| `shared/fonts`, `shared/shell-common` | Shared optional font payload and auxiliary theme recipes |

`themes/` contains one theme package per folder. Shared optional dependencies
live in `shared/`; core resources and contracts contain no concrete theme references.

Activate any installed appearance with the same native Godot assignment:

```gdscript
ui_root.theme = load("res://rookframe/ui/themes/silkbound-ledger/theme.tres")
```

Replace `silkbound-ledger` with `fantasy` or `cyberpunk`. Keep using the shared
`res://rookframe/ui/components/...` scenes, including rich material/motion
components. Installation does not activate a theme. See the
[activation contract](ui-kit/docs/world-theme-styling.md).

## Run the showcase

Use Godot 4.7 and Python 3.9+ from the repository root:

```sh
python3 tools/workspace.py prepare
godot --headless --editor --path showcase --import --quit
godot --path showcase
```

Run `prepare` after changing package sources. It copies the current local packages
into the ignored showcase runtime and removes stale installed files. Edit the
owning package, then prepare again. `python3 tools/workspace.py verify` rejects
stale copies and checks generated-art provenance. No network or external UI Kit
pin is used. `workspace.json` records package dependencies and import revisions;
the monorepo revision now identifies kit, themes and showcase together.

The native showcase opens a component catalogue with grouped navigation, search,
and a dedicated view for each component's variants and states. To open one component
directly, append `-- --component=field` to the Godot launch command.

## Install in a consumer

Check out the required monorepo revision, then run:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project
# Optional themes; each can be installed independently:
python3 tools/workspace.py install --destination /path/to/godot-project --theme silkbound-ledger
python3 tools/workspace.py install --destination /path/to/godot-project --theme fantasy --theme cyberpunk
```

The installer copies runtime resources and legal notices only. Components use
native defaults until the host assigns an installed canonical Theme. Keep using
the core scenes for every appearance. Existing inherited scene paths, native Theme
resources and licensed assets remain compatibility entry points. Installed paths
remain `res://rookframe/ui/`; source folders are package boundaries, not new
Godot resource prefixes. Existing UIDs and asset licenses are retained.
See [v2 migration steps](docs/migration-to-v2.md) for the breaking path and property changes.

## Checks

```sh
python3 -m unittest discover -s tests
python3 showcase/tools/verify_sources.py
godot --headless --path showcase --script res://tests/specimen.gd
godot --headless --path showcase --script res://tests/current_design_system.gd
godot --headless --path showcase --script res://tests/editor_components.gd
godot --headless --path showcase --script res://tests/switch.gd
```

Component test setup is in [ui-kit/README.md](ui-kit/README.md). Inspect native
captures at desktop, tablet and phone sizes before visual acceptance. The
[design contract](ui-kit/docs/design-system/principles.md) owns design rules;
[Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906)
holds human discussion and review evidence.
