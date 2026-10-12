# Native Controls and composition recipes

The UI Kit is native-first: Godot owns control behavior and Rookframe supplies
Theme coverage, semantic variation names, and recipes. Do not put a
pass-through scene or script around an adequate built-in node.

## Inputs and choices

- Use `LineEdit` and `TextEdit` directly when a visible label/help/error
  relationship is not needed. Minimum target height is 44px; multiline entry
  starts at 112px.
- Use `SpinBox` for numeric entry and `HSlider`/`VSlider` for bounded ranges.
  Give each an accessibility name that communicates the unit and allowed
  range.
- Use `CheckBox` or `CheckButton` for independent booleans. Use `CheckBox`
  instances with one `ButtonGroup` for an exclusive radio set when ordinary
  labelled options are sufficient.
- The shared `CheckBox` theme supplies 22px neutral outlined/filled indicators and
  disabled variants from the canonical controlled-field recipe. Retain a 44px
  minimum label row and native keyboard/accessibility state.
- Use `OptionButton` for one selection from a compact closed list.
- A form stack is an ordinary `VBoxContainer` with 16px semantic separation.
  Compose `TextField`, `TextArea`, native choices, and actions in source-order
  focus order.

## Tabs, grids, lists, and trees

- Use `TabContainer` when one already-loaded aggregate owns several panels.
  Add every panel once and allow native `current_tab` behavior to retain the
  selected panel. Tab changes must not secretly fetch or remount the task.
- Use fixed `GridContainer` columns when the column count is part of the
  content. Use `AdaptiveGrid` only when cell count must change with measured
  container width.
- Use `ItemList` for dense flat selection and `Tree` for hierarchical or
  multi-column records. Both retain native incremental search, keyboard
  movement, activation, and selection behavior. Empty/loading/error state is a
  sibling `TaskState`, not a fake item.
- Use `ScrollContainer` as the sole owner of body scrolling. Disable horizontal
  scrolling for reading and form tasks unless horizontal content is explicitly
  part of the contract.

## Windows, dialogs, popups, and menus

- Use `Window` directly for a normal native or embedded window. Rookframe Theme
  styles embedded borders and the title. Connect `close_requested`; Godot does
  not automatically close a Window.
- Use the public `Dialog` for Rookframe acknowledgement and confirmed decisions.
  It keeps native `Window` modality and keyboard focus while supplying the
  blocking scrim, semantic icon header, bounded message, optional body,
  content-driven height, and one explicit footer action hierarchy. Choose a
  visible tone that matches the decision; do not encode semantics in color
  alone.
- Use the public `FilePickerDialog` when selecting a file is part of a
  Rookframe task. It provides places, history, breadcrumbs, folder search,
  extension filters, compact icon-left file rows, preview context, and explicit
  confirmation. Paths remain in the preview instead of covering file rows as
  hover tooltips. The host remains responsible for validating and loading the
  emitted path.
- Built-in `AcceptDialog`, `ConfirmationDialog`, and `FileDialog` remain valid
  for platform-default utilities that intentionally do not use the Rookframe
  composition. Do not style or traverse their private child trees to imitate
  the public components.
- Use `PopupPanel` for temporary custom content and `PopupMenu`/`MenuButton`
  for action or option menus. Godot already owns viewport placement,
  incremental search, keyboard movement, activation, Escape, and click-away
  dismissal.
- When opening a context menu from an existing row, call a native Popup at the
  source position, focus the first enabled item, and restore focus to the
  source row after dismissal when it still exists. Disabled menu items remain
  readable and unfocusable.

Managed Surface is not a replacement for `Window`. It supplies the retained
dock/float state and fixed-region task relationship that a native Window does
not own. A host may place the same Managed Surface inside an embedded Window
when floating.

## Layout recipes

| Intent | Native or public composition |
| --- | --- |
| Column/row | `VBoxContainer` / `HBoxContainer` |
| Wrapping toolbar or action group | `HFlowContainer`; use `AdaptiveToolbar` when leading/trailing lanes must remain stable |
| Fixed grid | `GridContainer` |
| Adaptive 2/3/4 grid | `AdaptiveGrid` with the desired `maximum_columns` |
| Stage/content | `ResponsiveSplit`, default 0.4 primary ratio |
| Task/detail | `ResponsiveSplit`, 0.5 primary ratio |
| Form stack | `VBoxContainer`, 16px separation |
| Content/section stack | `VBoxContainer`; `Section` for each framed semantic group |
| Summary region | `HFlowContainer` for independent facts or `MetricStrip` for equal facts |
| Task actions | `ActionBar`; related controls remain nested in source-order groups |
| Search/count/filter/actions | `AdaptiveToolbar` |
| Acknowledgement or confirmed decision | `Dialog` |
| Designed open-file task | `FilePickerDialog` |
| Semantic icon actions | `IconActionGrid` plus native Buttons |
| Body scrolling | one `ScrollContainer` |

## Image display

Use native `TextureRect` with `expand_mode = IGNORE_SIZE` and an intentional
stretch mode. `KEEP_ASPECT_CENTERED` is appropriate for icons or bounded art;
`KEEP_ASPECT_COVERED` is appropriate for a square media preview that may crop.
Use `ImageField` only when replacement behavior and adjacent help/error copy
are required.

## Auxiliary shell-theme Switch

Instance `res://rookframe/ui/menu/Switch.tscn` under either auxiliary Theme. The shared
Usage token is `components.switch`, mapped to native `components_switch` and
`components_switch__compact` variations. Fantasy uses its buttons' textured
walnut and beveled brass casing, with material lighting for selection and focus.
Cyberpunk uses their alloy faces, cut corners, depth and cyan selection edges.

Set `title` and optional `description` for the card's copy; leave native
`Button.text` and `icon` empty. Selected cards show the same checkmark resource
as the current theme's dropdown, including its disabled tint. Unselected cards
reserve the icon's space, so selection never shifts the copy. The native toggle
state supplies the accessible selection state.

Set `compact` or call `set_compact(bool)` for density. The recipe manages its
minimum size: at least 116 px regular / 88 px compact, growing for wrapped copy.
Each card remains a native toggle Button with `button_pressed`, `toggled(bool)`,
`pressed`, `disabled`, `shortcut`, and keyboard focus. Theme and density changes
preserve selection. The title and description supply accessible copy; explicit
`accessibility_name` and `accessibility_description` take precedence.

Use `res://rookframe/ui/menu/SwitchGroup.tscn` for related options. Add Switch
instances to `get_options()` (the native BoxContainer at `Inset/Options`), and
assign the same host-owned `ButtonGroup` to those cards for exclusive selection.
Set one card's initial `button_pressed = true`. Independent groups use separate
ButtonGroups; standalone cards can toggle independently.

SwitchGroup supplies the existing `menu_group` material: stone tray in Fantasy,
chassis tray in Cyberpunk. It supports any number of options. Cards share a row
using a preferred card width of 320 px regular / 280 px compact; when the row
would not fit, the whole group stacks vertically. The threshold also accounts for padding, gaps and
larger native card minimums. Adding, removing or hiding options recomputes the
layout. Set `compact` on the group to update its padding, spacing and cards.
The corresponding Theme variations are `components_switch_group` and
`components_switch_options`, with `__compact` variants.

The **Switch** section follows Buttons in the Menu showcase and demonstrates
two- and three-option groups, responsive stacking, and disabled selected/unselected
states. Run its integration check in the separate design specimen with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/switch.gd
# Omit --headless and append -- --capture-dir=/tmp/switch to render both themes.
```

## Auxiliary shell-theme editor controls

These auxiliary editor recipes exercise Fantasy and Cyberpunk theme mappings.
Fantasy reserves carved brass fittings for primary actions. Tools, secondary
actions, and dropdowns use recessed walnut with a slim, beveled brass casing and
gently rounded corners, alongside
textured stone rails/panels and walnut inset/log surfaces.
Cyberpunk uses the menu's alloy switches, emissive actions, and virtual
chassis materials. Silkbound Ledger remains canonical; these examples do not change the Main Menu.

| Scene under `res://rookframe/ui/editor/` | Use |
| --- | --- |
| `EditorToolButton.tscn` | Square icon tool, 64px regular / 52px compact |
| `EditorActionButton.tscn` | Primary labelled action; optional native icon |
| `EditorToolRail.tscn` | Framed native `Tools` BoxContainer; set `vertical = false` for a horizontal rail |
| `EditorSurface.tscn` | PanelContainer with native content sizing and material padding |

Buttons expose `compact` / `set_compact(bool)` and `usage`:
`editor.button.tool`, `editor.button.action`, or `editor.button.standard`.
The `action` usage is primary; `standard` is secondary.
Use native `icon`, `text`, `disabled`, `shortcut`, `pressed`, `toggled`, and
`toggle_mode`. Give icon tools an explicit `accessibility_name` and `tooltip_text`.
For exclusive selection, assign the same `ButtonGroup` to the participating
buttons; create it once in the owning scene so instanced recipes share it.
Selection survives live theme and density changes. The recipes reserve their
target height and square tool width; native Button sizing accommodates copy.

Surface variations are `editor_surface_panel`, `editor_surface_rail`,
`editor_surface_inset`, and `editor_surface_log`. Append `__compact` for compact
padding. Place a normal Container inside a surface and add content to that
Container. Surface gaps stop pointer input from falling through to the world;
hosts should handle world input through `_unhandled_input`. Hosts own tool
actions, placement, dismissals, and scene data.

The specimen’s auxiliary In-game editor catalogue page has native state previews and an interactive
tool/layer/placement example. Run its input, layout and material checks with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/editor_components.gd
# Omit --headless to render evidence for both themes and densities:
/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tests/editor_components.gd -- --capture-dir=/tmp/editor-components
```

## Auxiliary shell-theme choices and native Settings controls

Instance `res://rookframe/ui/menu/MenuChoice.tscn` with the Fantasy or Cyberpunk
Theme. This native OptionButton binds its popup Theme, puts the selected check
at the trailing edge, and bounds long menus to the available space above or
below the field. Item IDs, metadata, tooltips, incremental search, keyboard
navigation and selection signals remain native. Set `compact` or call
`set_compact(true)`; the popup follows the density. Theme/density changes dismiss
an open popup before refreshing. Give the field an `accessibility_name`.
Minimum heights are 64/48 px in Fantasy and 52/48 px in Cyberpunk; containers
choose the width.

For a bare OptionButton, set `get_popup().theme_type_variation` to
`settings_popup` or `settings_popup__compact`. Set a ScrollContainer's vertical
scrollbar variation to `settings_scrollbar`. Use
`Control.CURSOR_POINTING_HAND` for native Settings buttons and scrollbars.
The menu/editor button recipes and MenuChoice supply this cursor, including
selectable popup items and popup scrollbars; disabled items/separators keep the
arrow cursor. Verify with `tests/menu_choice.gd` in UI Kit and
`tests/current_design_system.gd` in the separate specimen.

For a plain Silkbound ScrollContainer, assign an intentional native scrollbar
thickness (the specimen uses `get_v_scroll_bar().custom_minimum_size.x = 16`).
Its flat StyleBoxes supply colors, not a minimum width. Check overflowing content
at phone size and verify that the thumb remains visible and draggable.
