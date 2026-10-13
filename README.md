# Rookframe UI workspace

The `next` branch brings the production UI Kit, native showcase and optional
Fantasy/Cyberpunk themes into one repository. This migration establishes the
package boundaries for the UI rework; existing component visuals are retained.

| Package | Contents |
| --- | --- |
| [ui-kit](ui-kit/README.md) | Shared controls, theme compiler, Silkbound default, component tests and contracts |
| [showcase](showcase/README.md) | Native examples, catalogue and integration checks from the design specimen |
| [themes/fantasy](themes/fantasy/README.md) | Fantasy theme mapping, materials and artwork |
| [themes/cyberpunk](themes/cyberpunk/README.md) | Cyberpunk theme mapping, materials, artwork and Exo 2 font |

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

## Install in a consumer

Check out the required monorepo revision, then run:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project
# Optional themes; either can be installed independently:
python3 tools/workspace.py install --destination /path/to/godot-project --theme fantasy --theme cyberpunk
```

The installer copies runtime resources and legal notices only. Installed paths
remain `res://rookframe/ui/`; source folders are package boundaries, not new
Godot resource prefixes. Existing UIDs and asset licenses are retained.
See [migration notes](ui-kit/MIGRATING.md) for the changed source layout.

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
