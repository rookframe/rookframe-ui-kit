# Native Controls and composition recipes

Core components inherit the consumer Theme or native Godot defaults.
Appearance belongs to the consumer or an optional theme package.


All Rookframe UI must be usable through the UI Kit's public resources under
`res://rookframe/ui/`, including standard controls and composition recipes.
Use UI Kit proxies for standard Godot elements wherever possible. A proxy
keeps the native node or resource and its properties, methods, signals, input,
focus, accessibility and layout behavior. Add custom behavior only for a
composition that Godot does not already provide; reuse existing kit components
for those compositions. Consumers address the public kit resource rather than
recreating the component in host code. Native nodes remain appropriate inside
kit implementations and for caller-owned content and layout in public slots.

The catalogue records each public scene, script or resource path. Proxy scenes
and resources are unthemed; appearance belongs to the consumer or an optional
theme package. Adding a proxy does not select or implement a theme override.

## Public native proxies

Paths below are relative to `res://rookframe/ui/components/`. Instance `.tscn`
resources with `PackedScene.instantiate()`. Their roots keep the listed native
class API. Load `.tres` groups once per owning scene, or call `duplicate()` for
independent runtime groups; assign the shared instance to participating native
controls. Group resources are local to each instantiated scene.

| Component | Public resource | Native root or resource | Usage |
| --- | --- | --- | --- |
| Button | `actions/button.tscn` | `Button` | `variant = SECONDARY` (`SECONDARY`, `PRIMARY`, `DESTRUCTIVE`, `EMBLEM`), `compact = false`, `layout = INLINE` (`INLINE`, `STACKED`); native text, icon, input, signals and toggle behavior. |
| Toggle | `actions/toggle.tscn` | `Button` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| ButtonGroup | `actions/button_group.tscn` | `HFlowContainer` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Select | `forms/select.tscn` | `OptionButton` | `variant = NATIVE` or `MENU`; `compact = false`. Native IDs, signals, search and selection remain unchanged. |
| SelectionGroup | `forms/selection_group.tres` | `ButtonGroup` | Assign one instance to Checkbox, Toggle or Choice buttons and set the initial selection. Duplicate per independent group. Native allow_unpress enables an optional choice. |
| Checkbox | `forms/checkbox.tscn` | `CheckBox` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| FavoriteToggle | `forms/favorite_toggle.tscn` | `CheckBox` | `RookframeFavorite` variation with no text and a 44 × 44 minimum. The caller sets `accessibility_name` and `tooltip_text` and owns favorites. |
| NativeSwitch | `forms/switch.tscn` | `CheckButton` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Input | `forms/input.tscn` | `LineEdit` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| NativeTextarea | `forms/textarea.tscn` | `TextEdit` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Slider | `forms/slider.tscn` | `HSlider` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| VerticalSlider | `forms/vertical_slider.tscn` | `VSlider` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| NumericInput | `forms/numeric_input.tscn` | `SpinBox` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Tabs | `navigation/tabs.tscn` | `TabContainer` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| ScrollArea | `layout/scroll_area.tscn` | `ScrollContainer` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| AspectRatio | `layout/aspect_ratio.tscn` | `AspectRatioContainer` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Separator | `layout/separator.tscn` | `HSeparator` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| VerticalSeparator | `layout/vertical_separator.tscn` | `VSeparator` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Direction | `layout/direction.tscn` | `VBoxContainer` | Set native layout_direction on this content container; use text_direction on mixed-direction child values. |
| Accordion | `surfaces/accordion.tres` | `FoldableGroup` | Assign one instance to Collapsible scenes for single-open sections. Duplicate per independent accordion; omit the group for multiple-open sections. |
| Collapsible | `surfaces/collapsible.tscn` | `FoldableContainer` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Card | `surfaces/card.tscn` | `PanelContainer` | Inherits Section: title, description, get_body_slot() and get_action_slot(). No implicit activation. |
| Label | `data/label.tscn` | `Label` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Typography | `data/typography.tscn` | `Label` | Native Label with the RookframeBody semantic role. Set theme_type_variation for other roles; fonts and appearance belong to the consumer. |
| Table | `data/table.tscn` | `Tree` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Item | `data/item.tscn` | `PanelContainer` | Display item inherits StructuredRow. Use Choice for selection and ActionRow for activation. |
| Avatar | `data/avatar.tscn` | `PanelContainer` | Set texture, initials and fallback_texture. Displays the supplied image, then initials, then fallback art. The host supplies the accessible identity. |
| Progress | `feedback/progress.tscn` | `ProgressBar` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| Spinner | `feedback/spinner.tscn` | `PanelContainer` | Inherits TaskState in LOADING state, including title, description, state and reduced_motion. No separate animation implementation. |
| Tooltip | `feedback/tooltip.tscn` | `Label` | Set text and return this Label from the source Control._make_custom_tooltip(). Godot owns the tooltip popup, timing, placement and dismissal. |
| ContextMenu | `overlays/context_menu.tscn` | `PopupMenu` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| DropdownMenu | `overlays/dropdown_menu.tscn` | `MenuButton` | Native properties, methods, signals, input and focus behavior remain unchanged. |
| AlertDialog | `overlays/alert_dialog.tscn` | `Window` | Inherits Dialog in CONFIRMATION tone, including confirmed/cancelled signals, open_dialog() and get_body_slot(). |

The Slider and Separator pages list both orientations. Accordion combines
`surfaces/accordion.tres` with `surfaces/collapsible.tscn`. Radio and toggle sets share
`forms/selection_group.tres` with Checkbox, Toggle or Choice buttons. Hosts still own required
initial selections, content, labels and actions. Card, Item, Spinner and Alert
Dialog inherit their existing core compositions without duplicating behavior.

For a tooltip, return an instance of `feedback/tooltip.tscn` with its `text`
set from the source control's `_make_custom_tooltip(for_text)` override. Godot
provides the native tooltip popup and lifecycle. The Tooltip showcase page
contains this small host-side factory.

## Button

Use `components/actions/button.tscn` for menu actions, editor commands, icon
tools and HUD tiles. Three independent axes describe it: `variant` is emphasis
(`SECONDARY` standard, `PRIMARY`, `DESTRUCTIVE` or `EMBLEM`), `layout` is content
arrangement (`INLINE` or `STACKED`), and `compact` / `set_compact(bool)` is
density. Normal targets
start at 52 × 52px and compact targets at 44 × 44px. Native text/icon sizing,
larger caller minima and the Theme's `minimum_height` can grow these targets.
Containers own placement and final width.

Use native `text` for a label and `icon` for an optional image. For icon-only
actions, leave `text` empty, set `icon`, and supply `accessibility_name` and
`tooltip_text`. Icons center automatically while the label is empty; restoring
the label restores its previous icon alignment. All three variants support text,
icon-with-text and icon-only content in both sizes. Native `icon_alignment`, `expand_icon`, `disabled`,
`shortcut`, `toggle_mode`, `button_group`, `pressed` and `toggled` remain usable.
Changing variant, size or inherited Theme retains the same control and selection.
Destructive actions do not implement confirmation or effects; the host owns them.
`reduced_motion = false` allows optional theme motion; setting it to `true`
settles that presentation immediately. Theme changes cancel the old presentation
and restore its overrides without changing native content or interaction.

`EMBLEM` is the most prominent emphasis, for one icon-only action such as the
quick roll at the start of a HUD bar. Leave `text` empty and set
`accessibility_name` or `tooltip_text`; without either, the Button warns once.

`STACKED` places the icon above the label, for HUD categories, builder tools and
picker choices. While stacked, the Button controls the native `icon_alignment`
(centre), `vertical_icon_alignment` (top), `autowrap_mode` (smart word wrap) and
`text_overrun_behavior` (no trimming); returning to `INLINE` restores the
caller's values. The label wraps between words and is never trimmed, and the
minimum width keeps the widest word whole. Scenes store `layout`, not the values
it controls. Godot adds no gap between a stacked icon and its label;
`icon_max_width` and the stylebox content margins shape the tile. Selection
stays native: set `toggle_mode` and share a `ButtonGroup`. Native Button names
itself from `text` for assistive technology.

The semantic Theme type is
`components_button[_primary|_destructive|_emblem][__stacked][__compact]`, for
example `components_button_primary__stacked__compact`. The component owns
`theme_type_variation`; consumers style these types in a native Theme. Godot
resolves a variation only when a Theme in the tree declares its base, so a
theme declares the chain (`…__stacked__compact` → `…__stacked` → `…` → `Button`).
Without mappings, every combination uses native Godot Button appearance.
No palette, font or Theme is installed by the component.

The scene UID remains `uid://nsflvqoc35wn`. Its public behavior script is
`components/actions/button.gd` (`uid://dthc7uwdw3f2`). The inherited Toggle scene
also supports these properties. Existing `menu/MenuButton*.tscn` and
`editor/Editor*Button.tscn` paths remain compatibility recipes for prior
consumers and optional presentation packages; new compositions use Button.

## Inputs and choices

- Use the `LineEdit` and `TextEdit` proxies when a visible label/help/error
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

- Use native `Window` behavior for a normal native or embedded window. Rookframe Theme
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
| Persistent game HUD | `HudBar` with Button `EMBLEM`, `IdentityPlate`, `VitalMeter` and stacked Buttons; see [HUD bar](#hud-bar) |
| Body scrolling | one `ScrollContainer` |

## HUD bar

Compose a persistent HUD from `layout/hud_bar.tscn`. Callers fill its slots and
connect native `pressed` and `toggled`; the bar owns only layout, density and
overflow. Anchor it bottom-centre in a non-container parent such as the HUD
layer: its profile measures that parent, and a shrink-to-fit container parent
would grow with the bar. The HUD Bar showcase page builds each composition below
with placeholder data.

A tile is a Button with `layout = STACKED`. Callers own `toggle_mode` and any
`ButtonGroup`.

| Composition | Leading | Identity | Category lane | Trailing / attached |
| --- | --- | --- | --- | --- |
| Character | Button `EMBLEM` (roll) | `IdentityPlate` with a `VitalMeter` in `VitalSlot` | Seven toggle tiles sharing one duplicated `selection_group.tres` with `allow_unpress = true`; `compact_category_limit = 4` | None |
| Creature | None | `IdentityPlate` without a vital | Four toggle tiles; `compact_category_limit = -1` | `ActionRow` showing current HP with a caller minimum width |
| Builder tools | None | None | Tool tiles; selection tools share a group with `allow_unpress = false`; the host toggles `visible` between mode sets | `AttachedSlot` with toggle tiles in their own groups and Choice `CARD` swatches |

A dice tray outside the bar uses the same tiles with `toggle_mode = false`, one
per die, a `numeric_input.tscn` modifier and a secondary Button.

Tiles carry no usage of their own; their container gives them context. A theme
that styles bar tiles differently from other stacked Buttons maps
`layout/hud_bar.tscn` in its `presentations` to a template that assigns a
profile Theme to `Bar/Row/CategorySlot` or `AttachedPanel/AttachedSlot`. The
profile overrides items only; the theme's main Theme declares the variation
chain. Godot asks the nearest Theme first, so a profile that defines native
`Button` or `CheckBox` items hides `components_button_*` or `RookframeFavorite`
declared above it; a full-theme profile, such as one scoped to StructuredRow,
must repeat those variations. A selected or raised tool is the profile's native `pressed` style.

A category tile's `toggled(true)` opens its list in a `Popover` anchored to the
tile: a TaskHeader with Show all and Close, then PaginatedContent of
StructuredRows whose action slot holds an ActionRow and a FavoriteToggle; use
TaskState when empty. Closing the list sets the tile's `button_pressed = false`
and returns focus to it. A tile in the More overflow is hidden, so anchor its
list to the HudBar instead. Choosing it there toggles the original tile, so
the caller's logic stays the same.

## Image display

Use native `TextureRect` with `expand_mode = IGNORE_SIZE` and an intentional
stretch mode. `KEEP_ASPECT_CENTERED` is appropriate for icons or bounded art;
`KEEP_ASPECT_COVERED` is appropriate for a square media preview that may crop.
Use `ImageField` only when replacement behavior and adjacent help/error copy
are required.

## Choice and Choice Group

Use `res://rookframe/ui/components/forms/choice.tscn` for a complete selectable target.
Use `variant = CARD` for the former selectable Switch presentation. The other
variants are `ROW`, `MARKED_ROW`, `MARKED_CARD` and `LIST`. Each variant uses the
same native toggle Button and public interface. Use `title`, `description`,
`leading_icon`, `marker_text` and `value_text` for content. Use `action_label`
and `selected_label` for the visible state copy. Package inclusion is host data:
set these labels to `Include` and `Included` on a marked variant.

`compact` controls density. `show_description` independently controls supporting
copy. Appearance, density and description changes retain the Button, selection,
connections and focus. Native `button_pressed`, `button_group`, `disabled`,
`shortcut`, `pressed` and `toggled` remain usable. `selection_changed(bool)`
mirrors native `toggled`. `set_selected(bool)` and `is_selected()` use the same
native state. Silent native updates refresh the displayed state on the next draw.
Explicit accessibility copy takes precedence over automatic title/description/value copy.

Cards retain the `components_switch` and `components_switch__compact` Theme
variations. Their checkmark reserves space when unselected. The default card
minimum is 116px, or 88px when compact; wrapped content can increase the height.
Optional Themes own materials, fonts and colors. Other variants retain their
existing semantic Theme variations and optional presentation resources.

Use `res://rookframe/ui/components/forms/choice_group.tscn` for responsive layout.
Add choices to `get_options()`. The group changes from a row to a column when
options no longer fit. Preferred option widths are 320px regular and 280px compact;
Theme constants can override them. Hidden options do not affect the layout.
`set_compact(bool)` updates the group and its children. The existing
`components_switch_group`, `components_switch_options` and `menu_group` Theme
variations remain available.

Choice Group does not select options. Assign one shared native `ButtonGroup` for
exclusive selection. Use `forms/selection_group.tres` or `ButtonGroup.new()`.
Set the initial selection in the host. Set `allow_unpress = true` when no
selection is permitted. Duplicate the resource for each independent group.
Omit `button_group` for independent choices.

## Compatibility shell-theme editor controls

These existing editor recipes retain semantic mappings from the consumer Theme.
Use the shared [Button](#button) for new labelled commands and icon tools.

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

## Select variants and native Settings controls

Instance `res://rookframe/ui/components/forms/select.tscn` with a consumer
Theme. Set `variant = MENU` for the former MenuChoice presentation. The default
`NATIVE` variant uses the stock OptionButton presentation. The menu variant binds its popup Theme, puts the selected check
at the trailing edge, and bounds long menus to the available space above or
below the field. Item IDs, metadata, tooltips, incremental search, keyboard
navigation and selection signals remain native. Set `compact` or call
`set_compact(true)`; the popup follows the density. Theme/density changes dismiss
an open popup before refreshing. Give the field an `accessibility_name`.
The consumer Theme supplies minimum heights; containers choose the width.
Without a custom selection marker, the popup keeps Godot's native checks and
scrollbars.

For a bare OptionButton, set `get_popup().theme_type_variation` to
`settings_popup` or `settings_popup__compact`. Set a ScrollContainer's vertical
scrollbar variation to `settings_scrollbar`. Use
`Control.CURSOR_POINTING_HAND` for native Settings buttons and scrollbars.
The menu/editor button recipes and Select menu variant supply this cursor, including
selectable popup items and popup scrollbars; disabled items/separators keep the
arrow cursor. Verify with `tests/menu_choice.gd` in the showcase and
`tests/current_design_system.gd` in the sibling showcase.

For a native ScrollContainer, assign an intentional native scrollbar
thickness (the specimen uses `get_v_scroll_bar().custom_minimum_size.x = 16`).
Its flat StyleBoxes supply colors, not a minimum width. Check overflowing content
at phone size and verify that the thumb remains visible and draggable.

## Auxiliary Chronicle surface

Use `res://rookframe/ui/chronicle/ChronicleSurface.tscn` for retained event histories,
recaps, quest journals and acquired lore under a consumer
Theme. See [the Chronicle contract](chronicle.md) for semantic scope, companion
text styles, density, reading margins and vertical resizing.

## Expansion recipes (RF-UI-EXPANSION-01)

The synthetic Settings and character examples are in
`showcase/examples/ui-expansion/native_recipes.gd`. Dedicated component pages
under `showcase/examples/components/pages/` consume the public proxies below.
The containing screen supplies one bounded scroll owner.
The host owns every value, action and translated string.

| Requirement | Capability | Composition | Observable result |
| --- | --- | --- | --- |
| NAT-01 | Select; Native Select | Use OptionButton. Keep native IDs and disabled items. Document native search settings. | Selection uses IDs. Disabled items cannot activate. Empty lists have no invalid selected index. |
| NAT-02 | Radio Group | Use ButtonGroup and CheckBox or Choice. | Required mode keeps one selected item. Optional mode permits none. The recipe states its initial selection. |
| NAT-03 | Checkbox | Use native CheckBox for one boolean. | Pointer, keyboard, and controller each change the value once. Mixed state is absent. |
| NAT-04 | Switch | Use CheckButton for an immediate boolean setting. | The host receives one change. Existing selectable Choice cards keep their separate contract. |
| NAT-05 | Toggle | Use Button.toggle_mode. | Pressed state remains distinct from focus and disabled state. |
| NAT-06 | Toggle Group | Use ButtonGroup for exclusive choice. Use independent toggles for multiple choice. | Group rules remain true after disabled-state and external-value changes. |
| NAT-07 | Button Group | Use ActionBar and native containers. | Actions keep independent behavior and source order during compact layout. |
| NAT-08 | Context Menu | Use PopupMenu. Provide pointer and explicit controller/touch activation. | Open at the source. Focus the first enabled item. Return focus after dismissal. |
| NAT-09 | Dropdown Menu | Use MenuButton and PopupMenu. | Activation requests an action. It does not silently set a field value. |
| NAT-10 | Dialog | Extend the existing Dialog only where a required test fails. | Body content fits the bounded area. One scrim blocks background input. Existing initial focus remains unchanged. |
| NAT-11 | Alert Dialog | Use the existing Dialog confirmation recipe. | Only Confirm emits confirmation. Cancel and window-close use the cancellation path. |
| NAT-12 | Tooltip | Use the native tooltip lifecycle and consumer-supplied tooltip content. | Tooltip content has no interactive action. Essential information remains available through activation. |
| NAT-13 | Accordion | Use FoldableContainer and FoldableGroup. | Single-open and multiple-open recipes work. The recipe states whether all sections can close. |
| NAT-14 | Collapsible | Use one FoldableContainer without a group. | Closed content receives no focus. Content state survives close and open. |
| NAT-15 | Tabs | Use TabContainer or TabBar with retained panels. | Disabled tabs cannot activate. Panel state survives tab changes. Hidden panels receive no focus. |
| NAT-16 | Input | Keep TextField, SearchField, and native LineEdit. | Keep selection, clipboard, undo, IME, and read-only behavior. Return commits as documented. |
| NAT-17 | Textarea | Keep TextArea and native TextEdit. | Keep wrapping, scrolling, selection, caret, and IME. Focus exit commits as documented. |
| NAT-18 | Table | Use Tree columns or existing StructuredRow TABLE/HEADER recipes. | Headers match cells. Numeric values align. Long content remains available at constrained width. |
| NAT-19 | Alert | Use Notice. | Title, description, tone, dismissal, and action slots keep their documented behavior. |
| NAT-20 | Empty | Use TaskState.EMPTY. | Empty data and zero filter results have different explanations. A supplied recovery action remains reachable. |
| NAT-21 | Progress | Use ProgressBar or TextureProgressBar. | Current value and limit have readable labels. Task progress and health/mana examples work. |
| NAT-22 | Spinner | Use the existing TaskState.LOADING foundation. | Loading has a text description. Reduced motion keeps a static indicator. Focus stays unchanged. |
| NAT-23 | Slider | Use HSlider or VSlider for one value. | Minima, maxima, steps, units, disabled state, and controller adjustment work. |
| NAT-24 | Numeric Input | Use SpinBox inside Field or Input Group. | Typed values follow native bounds and step rules. The recipe states when the value commits. |
| NAT-25 | Scroll Area | Use ScrollContainer and native scrollbars. | Wheel, touch, scrollbar drag, and focus-follow behavior work. Nested scroll owners are absent. |
| NAT-26 | Aspect Ratio | Use AspectRatioContainer and TextureRect. | Fit and crop examples keep the selected ratio during resize. |
| NAT-27 | Card | Use Section or existing surfaces. | Header, body, and actions remain readable. A display card has no implied activation. |
| NAT-28 | Item | Use StructuredRow, Choice, or ActionRow by purpose. | Display, selection, and activation remain separate documented behaviors. |
| NAT-29 | Badge | Use the existing Badge. | Text communicates status without color. Long labels do not cover adjacent actions. |
| NAT-30 | Avatar | Use TextureRect and a fallback recipe. | A missing image shows host-supplied initials or a generic icon. The identity has an accessible name. |
| NAT-31 | Button | Use native Button and current theme variations. | Text and icon actions work with each input mode. Disabled actions emit no activation. |
| NAT-32 | Label | Use native Label and Field relationships. | Each input has an unambiguous name. Display labels do not add focus targets. |
| NAT-33 | Separator | Use HSeparator and VSeparator. | The separator follows the active theme. It adds no focus target. |
| NAT-34 | Typography | Use the requirements in Section 06. | The typography specimen passes the required sizes, languages, and text scales. |
| NAT-35 | Direction | Use native text and layout direction. | RTL layout, mixed-direction values, and focus navigation pass the required examples. |

Native OptionButton uses `get_item_id(index)` in its selected-index callback.
Enable `get_popup().allow_search` for native incremental search. Clear an empty
list with `clear()`; never select index zero in an empty list.

Required radio groups initially select the first enabled option. Optional groups
set `ButtonGroup.allow_unpress = true` and initially select none. The host keeps
a required selection eligible when it changes availability. Independent toggle
buttons permit multiple selections; a shared ButtonGroup makes them exclusive.

Context menus expose the same source action through pointer, keyboard, controller
and touch. Dropdown menu activation requests an action rather than changing a
field value. The native popup captures dismissal and restores source focus.

FoldableGroup provides single-open accordion behavior; independent
FoldableContainers permit several open sections. Both recipes allow all sections
to close and retain child controls. TabContainer retains every panel.

SpinBox commits typed content on native Return or focus exit; arrows change its
value immediately. Hosts use `value_changed` for immediate settings. Read-only
LineEdit and TextEdit retain native selection and copy.

Tree supplies one bounded table scroll owner. Numeric columns align right; full
long values remain in accessible text and tooltips. Sorting, column filters,
column visibility and editing are outside this read-only recipe.

Avatar initials are supplied by the host. When no image or initials are available,
use the semantic `person.svg` icon and a host-supplied accessible identity.
Progress examples require finite values and a finite maximum above the minimum;
clamp only the displayed value. Use a labelled TaskState.LOADING for unknown totals.
TaskState's additive `reduced_motion = false` property stops its spinner when true
and keeps the same labelled loading state and focus.

Typography uses the owning theme's semantic roles and regional companions. Core
contains no fonts. Set native `layout_direction` for RTL, preserve source order,
and use LTR `text_direction` on mixed paths, IDs and numeric values.
