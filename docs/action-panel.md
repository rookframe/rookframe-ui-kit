# Action Panel

`res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn` composes
the approved offset leather leaves. It owns appearance, content sizing and paired
connectors. The caller owns its ordinary Godot Controls, signals and system rules.
It contains no targeting, dice, difficulty, permission or combat logic.

Instance it in an authored scene, enable **Editable Children**, then add Controls
to the following public slots. A single `action_section.tscn` accepts an ordinary
Container child; add as many sections as the action needs. Rows within a section
are ordinary native Containers. Do not make a separate leaf for every fact.

Open `examples/action-panel/action_panel_example.tscn` and run the current scene
(F6). Its first section is authored in the scene tree; **Add section** and
**Remove section** exercise the programmatic path. Compact and footer toggles
reuse the same content. A native ScrollContainer bounds the whole example.

| Slot | Stable editor path | Runtime getter |
| --- | --- | --- |
| Header | `Header/Leaf/HeaderSlot` | `get_header_slot()` → VBoxContainer |
| Emblem | `Header/Emblem/Leaf/EmblemSlot` | `get_emblem_slot()` → CenterContainer |
| Sections | `Sections/SectionsSlot` | `get_sections_slot()` → VBoxContainer |
| Footer | `Footer/Leaf/FooterSlot` | `get_footer_slot()` → VBoxContainer |

The root is a stock VBoxContainer. `compact` defaults to false; it reduces the
offsets and emblem footprint without rebuilding children. `show_emblem` and
`show_footer` default to true. Hiding the footer removes its space and connectors.
Children keep their identity, focus and input connections through layout changes.
Callers choose compact row composition; the panel does not infer system semantics.

The same scenes work programmatically:

```gdscript
var panel = preload("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn").instantiate()
add_child(panel)
var section = preload("res://rookframe/ui/components/surfaces/action_panel/action_section.tscn").instantiate()
var rows := VBoxContainer.new()
section.add_child(rows)
panel.get_sections_slot().add_child(section)
# Add Labels, Buttons, SpinBoxes, authored scenes, etc. to rows.
panel.show_footer = false
```

Use the shared `RookframeActionIcon` Button variation for a centered 24px glyph
inside a 44px target. `RookframeActionRoll` retains the approved illustrated D20;
all four states use the same source image with material tint and pressed offset.
Systems using another die or action supply an ordinary Button and their own icon.
`RookframeActionDivider` supplies the thin copper separator. Labels and controls
inherit EB Garamond; the owning system supplies localization and accessible names.

The companion `action_panel_theme.tres`, nine-patch Resources and fixed connector
atlas are shared assets. Authors never redraw a skin to add a field or section.
The theme contains no rule-specific text. Nine-patch rendering uses a 0.4 texture
scale inside each leaf, keeping the border and material density fixed while native
content lays out in logical units. Decorative nodes ignore input; gaps pass through
to the tabletop. The host remains responsible for managed-window placement and
viewport bounds. An oversized action can put its native content in a ScrollContainer.

`action_leaf.gd.surface` selects Body (0), Header (1), Footer (2), or Emblem (3).
Consumers normally instance `action_section.tscn`, whose default is Body.
Other child paths and the connector renderer are implementation details.

The package test uses both authored Mörk Borg composition and programmatic stock
Controls; the UI Kit suite checks growth, hiding, compact transitions and state
identity. Run `tests/action_panel.gd` with the repository's GdUnit runner.

This is an additive, opt-in extension of Silkbound Ledger, approved in the attack
silhouette study. Existing screen skins do not change. Asset origin and generation
prompts are recorded in `assets/action-panel/provenance.json`; existing game-icons
SVG shapes remain independently attributed by their owning icon registry/Package.
