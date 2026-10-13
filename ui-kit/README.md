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

The interactive Godot catalogue, native examples and integration checks live in
[the sibling showcase](../showcase/README.md), which consumes current local
package sources. Fantasy and Cyberpunk are optional packages in `../themes/`.

## Consume a revision

Check out the required monorepo commit and run the installer from its root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project
```

Install optional materials with `--theme fantasy` or `--theme cyberpunk`.
Public Godot paths remain `res://rookframe/ui/`; the installer includes runtime
resources and legal notices, excluding tests and examples.

## Support and verification

Normal resources under `rookframe/ui/` are public; `_internal/` is unsupported.
Paths, UIDs, semantic Theme variations and documented behavior participate in the
kit's independent SemVer contract. [Compatibility](docs/compatibility.md) defines
the relationship to SDK Editions and Rookframe Versions. An exact Git revision is
available source, not a claim that a stable release has been published.

From `ui-kit/`, install the development-only runner:

```sh
godot --headless -s plug.gd install
```

Import with `godot --headless --editor --path . --import --quit`, then run the applicable
suite, for example:

```sh
godot --headless --path . --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests/action_panel.gd -c -rd reports/action-panel
```

Require a fresh nonempty report with no failed, skipped or flaky cases. Use the
sibling showcase for rendered inspection. Host placement, domain behavior and
networking are tested in the host, not simulated in the UI Kit.

Rookframe-owned source/assets use [MIT](LICENSE); third-party resources retain
[their notices](THIRD_PARTY_NOTICES.md). `rookframe/ui/assets/generated-assets.json`
tracks generated production art by stable replacement ID, path and checksum.
Design discussion, proposals and review evidence live in [Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906).
