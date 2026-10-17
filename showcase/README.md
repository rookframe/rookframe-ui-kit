# Rookframe native component catalogue

An executable reference for agents implementing Rookframe UI. It consumes the sibling UI Kit and optional theme packages and instances its production resources with synthetic data.
Silkbound Ledger, including leather leaves and motion, is canonical.
The showcase explicitly instances the optional Silkbound inherited scenes.
Base UI Kit components remain unthemed. The Main Menu remains Silkbound.
Fantasy/Cyberpunk are auxiliary shell-theme experiments;
System Extension shell selection remains proposed, not a released SDK facility.
Direct Godot Main Menu overrides are allowed but unsupported.

## Run and inspect

Use stock Godot 4.7.2 (Compatibility renderer; C# is not required here):

```sh
python3 ../tools/workspace.py prepare
godot --headless --editor --path . --import --quit
godot --path .
```

The project opens `examples/components/catalogue.tscn`: a native Godot catalogue
with one view per component or native composition recipe. Navigation groups
components by purpose: Actions, Forms & selection, Navigation, Layout, Surfaces,
Data display, and Feedback & overlays. Each view offers separate state and variant
examples using production resources, plus local synthetic interaction feedback.

Search by component, group, or purpose. Ctrl/Cmd+K focuses search; Enter opens
the first match. Previous/Next follow group order. At narrow widths, Components
opens the navigation; Escape returns to the current view. Desktop views include
section links. Reduced motion updates the active examples without rebuilding
their state. Light/dark changes the catalogue chrome; specimen appearance remains
the selected production resources.

Open a dedicated view directly with `godot --path . -- --component=field`.
Route IDs and page ownership are listed in `examples/components/manifests/`.
Every manifest entry points to its own script under `examples/components/pages/`;
`component_page.gd` supplies shared example framing. When adding a component,
add a dedicated page with meaningful variants/states and declare the covered
public resource or native capability in its manifest.

**Motion lab** opens the retained Silkbound action-leaf laboratory. Choose a recipe, long content,
English/Russian/Japanese, bright/dark backdrop, extra rows and reduced motion.
Replay, pause or slow the native motion. Open a native-size preview for desktop
1920 × 1080, tablet 1024 × 768 or phone landscape 844 × 390; the preview's client
area is the selected canvas and contains no laboratory toolbar.

Inside the laboratory, **Controls** opens the original Silkbound state catalogue. **Shell experiments** opens
Fantasy/Cyberpunk controls, settings and editor examples. These are reference
consumers of theme mappings, not the Rookframe Main Menu.

## Authoring examples

| Example | Source | Production resource |
| --- | --- | --- |
| Grouped component views and interactive states | `examples/components/catalogue.tscn` and `pages/` | Public component scenes and documented native recipes |
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
python3 tools/check_component_pages.py
godot --headless --path . --script res://tests/component_catalogue.gd
godot --headless --path . --script res://tests/component_catalogue_interactions.gd
godot --path . --script res://tests/component_catalogue.gd -- --capture-dir=/absolute/temp/path
godot --path . --script res://tests/specimen.gd -- --capture-dir=/absolute/temp/path
godot --headless --path . --script res://tests/current_design_system.gd
godot --headless --path . --script res://tests/editor_components.gd
godot --headless --path . --script res://tests/switch.gd
```

The component checks verify registry coverage, dedicated views, navigation,
search, reduced motion, and layout at all three native sizes. Captures include
the first and final examples on every page. The specimen check exercises the
laboratory and its native-size content cases; omit capture-dir for checks only.
Catalogue checks travel with the catalogue; reusable
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

The copied runner is development tooling. Theme component integration suites live
in `tests/theme_components`; core-only checks remain in `ui-kit/tests`.
From the workspace root, run the theme suites in a disposable consumer with a
graphical renderer to include fractional-scale wizard badge checks:

```sh
python3 tools/check_components.py
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

The native boundary comparison is `examples/theme-boundary/theme_boundary.tscn`.
`tests/theme_boundary.gd` checks native inheritance and dynamic selection at all
three target sizes; pass `-- --capture-dir=/tmp/theme-boundary` to capture it.

## UI expansion specimens

Run `godot --path showcase res://examples/ui-expansion/specimen.tscn` from the
workspace root. The retained tabs cover native recipes, Settings, Details,
Inventory, Assets, Feedback and language specimens. The toolbar changes the
three optional themes, eight languages, 1.0/1.5 text scale, long text and motion.

```sh
godot --path showcase --script res://tests/ui_expansion.gd -- --capture-dir=/tmp/rookframe-ui-expansion/captures
godot --path showcase --script res://tests/ui_expansion_recipes.gd
```

The automated matrix captures appearance; inspect the captures before claiming
visual acceptance. Real IME, screen-reader announcements, touch hardware and
controller hardware still require their native platform input routes. The
standalone core contract runner is documented in the UI Kit README.
Arabic and Hebrew specimen fonts are test assets under `examples/ui-expansion/fonts`;
their OFL licenses, source URLs and SHA-256 checksums travel with them. The
existing explicit Silkbound CJK companions supply Japanese, Chinese and Korean.
