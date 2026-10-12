# Rookframe UI Kit

Production Godot resources for **Silkbound Ledger**, Rookframe's canonical default
design. Leather leaves, bindings and ink/physical motion are its current iteration.
The Main Menu remains Silkbound Ledger. Fantasy and Cyberpunk are auxiliary
shell-theme experiments; System Extension shell theme selection remains proposed.

## Agent entry points

Read [the design contract](docs/design-system/principles.md) before UI work.
Use [public components](docs/public-components.md), [native recipes](docs/native-controls-and-recipes.md)
and [linked action/HUD leaves](docs/action-panel.md) for implementation.
`rookframe/ui/catalogue.json` indexes the public resources.

The interactive Godot catalogue, native-size examples and their integration checks
live in [rookframe-design-specimen](https://github.com/rookframe/rookframe-design-specimen). It consumes this kit at an exact
commit and opens Silkbound Ledger first. This repository contains runtime resources
and component tests; the catalogue is not installed into consuming applications.

## Consume an exact revision

Commit gd-plug and a `plug.gd` declaration in the consuming project:

```gdscript
extends "res://addons/gd-plug/plug.gd"

func _plugging() -> void:
    plug("rookframe/rookframe-ui-kit", {
        "commit": "64c727b89fbf05834e8c7b4f34740d984b48b007",
        "include": ["rookframe/ui"],
    })
```

Run `godot --headless -s plug.gd install`. Instance public scenes directly and
use their native Controls, Containers, Resources and signals. Assign
`res://rookframe/ui/theme/silkbound_theme.tres` to ordinary Silkbound surfaces;
the Action Panel and hinged leaf supply their own material treatment.

## Support and verification

Normal resources under `rookframe/ui/` are public; `_internal/` is unsupported.
Paths, UIDs, semantic Theme variations and documented behavior participate in the
kit's independent SemVer contract. [Compatibility](docs/compatibility.md) defines
the relationship to SDK Editions and Rookframe Versions. An exact Git revision is
available source, not a claim that a stable release has been published.

Bootstrap the development-only runner on a fresh checkout:

```sh
python -c "from pathlib import Path; from urllib.request import urlretrieve; p=Path('addons/gd-plug'); p.mkdir(parents=True, exist_ok=True); base='https://raw.githubusercontent.com/imjp94/gd-plug/209276d1f00d14b49b74403d9839f29598e9a8eb/'; urlretrieve(base+'addons/gd-plug/plug.gd', p/'plug.gd'); urlretrieve(base+'LICENSE', p/'LICENSE')"
godot --headless -s plug.gd install
```

Import with `godot --headless --editor --path . --import --quit`, then run the applicable
suite, for example:

```sh
godot --headless --path . --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests/action_panel.gd -c -rd reports/action-panel
```

Require a fresh nonempty report with no failed, skipped or flaky cases. Use the
separate specimen for rendered inspection. Host placement, domain behavior and
networking are tested in the host, not simulated in the UI Kit.

Rookframe-owned source/assets use [MIT](LICENSE); third-party resources retain
[their notices](THIRD_PARTY_NOTICES.md). `rookframe/ui/assets/generated-assets.json`
tracks generated production art by stable replacement ID, path and checksum.
Design discussion, proposals and review evidence live in [Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906).
