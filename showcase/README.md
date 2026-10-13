# Silkbound Ledger native specimen

An executable reference for agents implementing Rookframe UI. It consumes the sibling UI Kit and optional theme packages and instances its production resources with synthetic data.
Silkbound Ledger, including leather leaves and motion, is canonical. The Main
Menu remains Silkbound. Fantasy/Cyberpunk are auxiliary shell-theme experiments;
System Extension shell selection remains proposed, not a released SDK facility.
Direct Godot Main Menu overrides are allowed but unsupported.

## Run and inspect

Use stock Godot 4.7.2 (Compatibility renderer; C# is not required here):

```sh
python3 ../tools/workspace.py prepare
godot --headless --editor --path . --import --quit
godot --path .
```

The laboratory opens Silkbound action leaves. Choose a recipe, long content,
English/Russian/Japanese, bright/dark backdrop, extra rows and reduced motion.
Replay, pause or slow the native motion. Open a native-size preview for desktop
1920 × 1080, tablet 1024 × 768 or phone landscape 844 × 390; the preview's client
area is the selected canvas and contains no laboratory toolbar.

**Controls** opens the Silkbound state catalogue. **Shell experiments** opens
Fantasy/Cyberpunk controls, settings and editor examples. These are reference
consumers of theme mappings, not the Rookframe Main Menu.

## Authoring examples

| Example | Source | Production resource |
| --- | --- | --- |
| Authored header/section; programmatic growing sections | `examples/action-panel/action_panel_example.tscn` and `.gd` | `components/surfaces/action_panel/action_panel.tscn` |
| Action/explanation composition | `examples/laboratory/sample.gd` | Action Panel public slots; native Controls |
| Hinged category leaf | `examples/laboratory/sample.gd` | `components/surfaces/hinged_leaf/hinged_leaf.tscn` |
| Read-only ledger composition | `examples/laboratory/sample.gd` | `theme/silkbound_theme.tres`; native Containers/Labels |
| Control states and locale fonts | `examples/catalogue/legacy_catalogue.tscn` | Silkbound public scenes and Theme |
| Auxiliary material variations | `examples/catalogue/visual_catalogue.tscn` | Fantasy/Cyberpunk recipe resources |

Production paths are relative to `res://rookframe/ui/`. The sample ledger is a
composition recipe, not a copy of Rookframe's Action Log implementation. Host-only
announcements, retained log records, replication and window placement remain
covered by `rookframe-godot/rookframe/tests/ActionLogPresentationTests.gd` and the
host integration suites. This project executes no game rules or network actions.

## Verify changes

```sh
godot --path . --script res://tests/specimen.gd -- --capture-dir=/absolute/temp/path
godot --headless --path . --script res://tests/current_design_system.gd
godot --headless --path . --script res://tests/editor_components.gd
godot --headless --path . --script res://tests/switch.gd
```

The first check exercises the laboratory and all native-size content cases; omit
capture-dir for checks only. Catalogue checks travel with the catalogue; reusable
component unit tests remain in the UI Kit. Review captured images as well as exit
status. Root/toolbars are author tools, not a new product screen authority.

The cross-package World Theme suite uses the same GdUnit runner as the kit.
After [installing that development runner](../ui-kit/README.md), run from the
workspace root:

```sh
mkdir -p showcase/addons
cp -R ui-kit/addons/gdUnit4 showcase/addons/
godot --headless --editor --path showcase --import --quit
godot --headless --path showcase --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests/world_theme.gd -c -rd reports/world-theme
```

The copied runner is ignored development tooling. Run the full kit component
suite with a graphical renderer to include fractional-scale wizard badge checks:

```sh
godot --path ui-kit --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests -c -rd reports/components
```

Run `python3 ../tools/workspace.py prepare` after changing a local package.
`tools/verify_sources.py` checks installed bytes against those sources and verifies
asset provenance. The monorepo revision identifies all packages together;
`../workspace.json` records the original import commits.

[UI Kit contract](../ui-kit/docs/design-system/principles.md)
owns shared design rules. [Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906)
holds rationale, proposals and studies; [RFG-367](https://linear.app/rookframe/issue/RFG-367)
holds the extraction archive and review evidence. Source uses MIT; installed
third-party resources retain the installed package notices.
