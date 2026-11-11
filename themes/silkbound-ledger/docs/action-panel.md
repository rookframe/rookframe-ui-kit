# Action Panel

Appearance in this reference describes the optional `silkbound-ledger` package.
Base components are unthemed and use native Godot defaults. To select the described
skin, install that package and assign
`res://rookframe/ui/themes/silkbound-ledger/theme.tres` to the owning Control.
Use the ordinary `res://rookframe/ui/components/` scenes. Base component paths/UIDs and behavior stay
public. See [migration notes](../../../docs/migration-to-v2.md).


`res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn` composes
the approved offset leather leaves. It owns appearance, content sizing and paired
connectors. The caller owns its ordinary Godot Controls, signals and system rules.
It contains no targeting, dice, difficulty, permission or combat logic.

Instance it in an authored scene, enable **Editable Children**, then add Controls
to the following public slots. A single `action_section.tscn` accepts an ordinary
Container child; add as many sections as the action needs. Rows within a section
are ordinary native Containers. Do not make a separate leaf for every fact.

In [the native specimen](../../../showcase/README.md), open
`examples/action-panel/action_panel_example.tscn` and run the current scene
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

On opening, the header appears first. Each lower leaf drops from its top bindings
in order, then all native content develops through ink together. `animate_open`
defaults to true; disable it for immediate presentation, or set `reduced_motion`
to skip motion. Hiding, removing a leaf, or changing the footer during the entrance
restores native presentation and input immediately. Controls remain in their slots;
temporary 3D faces render only blank leather and are freed when the entrance ends.
The leaf folds behind its upper neighbour, accelerates downward, and settles with
a small swing. The host instances `render_warmup.tscn` during tabletop loading to
draw the materials and ink once for Compatibility shader compilation; its viewports
then stop. Moving faces avoid resizing unchanged textures and stop drawing at rest.

The same scenes work programmatically:

```gdscript
var panel = preload("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn").instantiate()
add_child(panel)
var section = preload("res://rookframe/ui/components/surfaces/action_panel/action_section.tscn").instantiate()
var rows := VBoxContainer.new()
section.add_child(rows)
panel.get_sections_slot().add_child(section)
# Add Labels, Buttons, OptionButtons, authored scenes, etc. to rows.
panel.show_footer = false
```

Use the shared `RookframeActionIcon` Button variation for a centered 24px glyph
inside a 44px target. The footer's content inset reserves its stepped edge so
hover and focus feedback stay on the material instead of crossing the cutout.
`RookframeActionRoll` retains the approved illustrated D20;
all four states use the same source image with material tint and pressed offset.
Systems using another die or action supply an ordinary Button and their own icon.
`RookframeActionDivider` supplies the thin copper separator. Labels and controls
inherit EB Garamond; the owning system supplies localization and accessible names.
Native Buttons, CheckBoxes, LineEdits and OptionButtons inherit the panel material
without per-control overrides. The standard `RookframePrimaryButton` and
`RookframeSecondaryButton` variations are scoped here too, including disabled,
hover, pressed and keyboard-focus states. Text actions use warm borders over
visible leather; primary actions use bone ink with dark text.
`RookframeActionTextField` and `RookframeActionSelect` remain optional aliases for
the native field styles. The PopupMenu keeps the same palette. Authors still set
a 44px minimum control height and connect ordinary native signals.

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
identity. Run `showcase/tests/theme_components/action_panel.gd` with the repository's GdUnit runner.

These leaves are the approved compact-surface iteration of Silkbound Ledger.
Long reading surfaces retain their ledger composition. Asset origin and generation
prompts are recorded in `assets/action-panel/provenance.json`; existing game-icons
SVG shapes remain independently attributed by their owning icon registry/Package.

## Hinged category leaf

`components/surfaces/hinged_leaf/hinged_leaf.tscn` is the matching animated
Control. Instance it with **Editable Children** and author ordinary Controls in
`Surface/Viewport/Root/Ink/Content`, or add them through `get_content()`.
Assign `action_panel_theme.tres` to `get_content().theme`: the native SubViewport
is a separate Theme inheritance boundary. Apply locale companion fonts to
content Controls, including Buttons, when required.
Set the root's position and size normally. `hinge_gap` (26px) and `hinge_inset`
(48px) place its two bindings; those remain visible when the leaf is folded.

`set_open(true)` performs the approved 800ms gather, flip, suspended approach,
impact and rebound, with the content developing through ink after contact.
`set_open(false)` fades and folds it away. Pass `false` as the second argument,
or set `reduced_motion`, for immediate changes. Read `is_open` and `animating`;
listen to `settled(open)` for completion. `reaction_changed(offset)` optionally
lets an adjacent support respond to the impact. Hiding the leaf cancels motion
and folds it; repeated calls safely replace an in-flight transition.

The authored scene uses stock SubViewports, Camera3D, MeshInstance3D, Tween and
canvas-item shaders. Its source Controls retain native input and focus when
open; input is suspended during motion. The 3D viewport runs only while moving,
and both viewports stop when folded. The soft shadow follows the moving corners.
`binding_pair.tscn` supplies stationary riveted tabs between adjacent leaves.
Neither component owns category semantics, selection, persistence or SDK calls.
The identity and badge nine-patches reuse the existing AI-named leather atlas;
this addition introduces no generated artwork.

## HUD bar

The canonical Theme maps the [HUD components](../../../ui-kit/docs/public-components.md#hud-components)
through `theme/hud_theme.tres`, a supplemental native Theme that declares every
HUD and Button layout chain (`…__stacked__compact` → `…__stacked` → `…`).
The bar, attached panel, identity plate and Emblem reuse the approved leather
regions (`body`, `hud_badge`, `hud_identity`, `connector`) through
`assets/action-panel/ai-generated-hud-leather-atlas.png`, a display-density
derivative drawn 1:1 by tiled StyleBoxTextures. Regenerate it from the
repository root with
`godot --headless --script themes/silkbound-ledger/tools/export-hud-leather.gd`;
the script prints the regions that `hud_theme.tres` uses. The attached panel
carries its two connector straps below its edge (`expand_margin_bottom`), and
they tuck behind the bar.

Stacked tiles use the ink tile with a copper rule. A selected tile is a bone fill
with ink label and pictogram and rises 3px through its `pressed` stylebox; focus
is a 2px bone ring outside the raised edge. Destructive tiles keep coral and
select to a coral fill with ink foreground. Vital levels differ by value and
track edge as well as hue: steady bone, wounded copper with an ink end mark,
critical coral inside a 2px coral track, depleted an empty muted outline.
FavoriteToggle draws an outline star when off and a filled star when on; the
disabled off star is dashed.

`layout/hud_bar.tscn` maps to `presentation/hud_bar.tscn`, which scopes
`theme/hud_identity_profile.tres` to `Bar/Row/IdentitySlot`. In the bar the
identity copy uses 20/15/18px name, detail and value with tight rows, so the
plate matches the tile height; elsewhere it keeps the general text roles.
