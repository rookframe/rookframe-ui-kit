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
