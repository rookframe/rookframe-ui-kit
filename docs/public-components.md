# Public component reference

Every scene and script in this document is public at its normal
`res://rookframe/ui/` path. Scene paths, scene UIDs, script paths, script UIDs,
root types, exported property names and defaults, signals, methods, slot names,
state names, and documented behavior are compatibility contracts within a
SemVer major line.

The machine-readable form of this reference is
`res://rookframe/ui/catalogue.json`.

## Public identities

| Public scene | Scene UID | Public behavior script and UID | Root type |
| --- | --- | --- | --- |
| `components/layout/adaptive_grid.tscn` | `uid://bqfivtkeswdra` | `components/layout/adaptive_grid.gd`, `uid://cwgli747u0cv2` | `GridContainer` |
| `components/layout/responsive_split.tscn` | `uid://ctbrwicbpnbko` | `components/layout/responsive_split.gd`, `uid://cgm6s0thbggch` | `BoxContainer` |
| `components/layout/task_header.tscn` | `uid://daiidltfcnxmc` | `components/layout/task_header.gd`, `uid://fu2nr35six6m` | `VBoxContainer` |
| `components/layout/compact_route_heading.tscn` | `uid://bc8nlg3pfa3ub` | `components/layout/compact_route_heading.gd`, `uid://c3gfgsec40cac` | `VBoxContainer` |
| `components/layout/section.tscn` | `uid://eakyhwvofovql` | `components/layout/section.gd`, `uid://cnqkqncrm3noo` | `PanelContainer` |
| `components/layout/action_bar.tscn` | `uid://fawromoaegwob` | `components/layout/action_bar.gd`, `uid://bhv4hi8nxqudi` | `BoxContainer` |
| `components/layout/adaptive_toolbar.tscn` | `uid://gbsncdddrctra` | `components/layout/action_bar.gd`, `uid://bhv4hi8nxqudi` | `BoxContainer` |
| `components/forms/text_field.tscn` | `uid://hcrialnjrunbn` | `components/forms/text_field.gd`, `uid://14x5hvhd0hgd` | `VBoxContainer` |
| `components/forms/text_area.tscn` | `uid://ibntwmikwuovm` | `components/forms/text_area.gd`, `uid://bb8xvwqqnaxb3` | `VBoxContainer` |
| `components/forms/search_field.tscn` | `uid://jhuolgtvtefyi` | `components/forms/search_field.gd`, `uid://bnvqayp06k4ud` | `VBoxContainer` |
| `components/forms/choice_row.tscn` | `uid://kipsbpkvppkfb` | `components/forms/choice_row.gd`, `uid://cneqvtm4mj43s` | `Button` |
| `components/forms/package_choice.tscn` | `uid://cj1dtt1u2dghw` | `components/forms/package_choice.gd`, `uid://bacunik1ndif2` | `Button` |
| `components/forms/package_choice_card.tscn` | `uid://cdlme6itdqmki` | `components/forms/package_choice.gd`, `uid://bacunik1ndif2` | `Button` |
| `components/forms/image_field.tscn` | `uid://ljsdqcdmawsqy` | `components/forms/image_field.gd`, `uid://cgrcfqykt0c7o` | `VBoxContainer` |
| `components/overlays/dialog.tscn` | `uid://87uetn404lqb` | `components/overlays/dialog.gd`, `uid://do77iyssrgyr2` | `Window` |
| `components/overlays/file_picker_dialog.tscn` | `uid://g4tupp4dkeeb` | `components/overlays/file_picker_dialog.gd`, `uid://2iqy4kt4qdkx` | `Window` |
| `components/feedback/notice.tscn` | `uid://mvkyfkqyexkga` | `components/feedback/notice.gd`, `uid://d1yvhlo6e2o2n` | `PanelContainer` |
| `components/feedback/task_state.tscn` | `uid://nrcsepslcftqf` | `components/feedback/task_state.gd`, `uid://c4soskilw12h6` | `PanelContainer` |
| `components/feedback/step_progress.tscn` | `uid://otcfjhowvcyxj` | `components/feedback/step_progress.gd`, `uid://du3i8msed1xq7` | `VBoxContainer` |
| `components/data/metric.tscn` | `uid://ptodnotxbclre` | `components/data/metric.gd`, `uid://b5m4p5k5ksqh7` | `PanelContainer` |
| `components/data/metric_strip.tscn` | `uid://qnxgatyloigoy` | `components/layout/adaptive_grid.gd`, `uid://cwgli747u0cv2` | `GridContainer` |
| `components/data/icon_action_grid.tscn` | `uid://rlkymfvqiatgk` | `components/layout/adaptive_grid.gd`, `uid://cwgli747u0cv2` | `GridContainer` |
| `components/data/badge.tscn` | `uid://sbfmvlonoxixc` | `components/data/badge.gd`, `uid://5m6r41nop671` | `PanelContainer` |
| `components/data/roll_row.tscn` | `uid://tcrguqtsprodb` | `components/data/roll_row.gd`, `uid://wo8rkw0btjpa` | `GridContainer` |
| `components/data/structured_row.tscn` | `uid://ukteoalflguqe` | `components/data/structured_row.gd`, `uid://vrrt25g1ko53` | `PanelContainer` |
| `components/data/key_value_row.tscn` | `uid://bj0vmkr6mxuyw` | `components/data/key_value_row.gd`, `uid://decjv735jvpfy` | `PanelContainer` |
| `components/data/action_row.tscn` | `uid://bevq4pos03l4p` | `components/data/action_row.gd`, `uid://xrhweteo63hd` | `Button` |
| `components/data/package_row.tscn` | `uid://c6dihfeyukjh` | `components/data/package_row.gd`, `uid://dxok8xtr1f1ai` | `PanelContainer` |
| `components/data/package_card.tscn` | `uid://d5mye7ybbq7rj` | `components/data/package_row.gd`, `uid://dxok8xtr1f1ai` | `PanelContainer` |
| `components/surfaces/managed_surface.tscn` | `uid://vhwxjcowiuacj` | `components/surfaces/managed_surface.gd`, `uid://dbt641tlogj02` | `PanelContainer` |

`components/surfaces/managed_surface_state.gd` is the public
`RookframeManagedSurfaceState` Resource with UID `uid://q51dth77eqqb`; it has no
scene identity.

## Editor composition

Instance a scene normally. Set its exported properties in the Inspector. For
content-bearing scenes, either enable **Editable Children** and add Controls to
the documented slot node or add content at runtime through the corresponding
`get_*_slot()` method. Only the documented slot names are public child paths;
all other child-node structure is an implementation detail.

Package code supplies copy, resources, callbacks, and domain state. The kit
owns only the visual, layout, focus, and interaction relationship described
here.

## Layout and navigation

| Scene / root | Public properties and defaults | Signals, methods, and slots | Behavior, focus, input, and accessibility |
| --- | --- | --- | --- |
| `adaptive_grid.tscn` / `GridContainer` | `minimum_columns = 1`; `maximum_columns = 4`; `minimum_column_width = 220.0` | `column_count_changed(column_count)` | Direct child Controls are equal-priority cells. Reflow uses measured width without recreating children, so source-order reading and focus order remain stable. Children own their accessible names and input. |
| `responsive_split.tscn` / `BoxContainer` | `compact_width = 720.0`; `primary_ratio = 0.4`; `compact_secondary_first = false` | `layout_profile_changed(profile)`; `get_primary_slot()`, `get_secondary_slot()`; `PrimarySlot`, `SecondarySlot` | Retains one two-region tree, weighted wide and stacked compact. Source order is primary then secondary unless the explicit compact flag reverses it; slotted Controls retain focus and accessibility state. |
| `task_header.tscn` / `VBoxContainer` | `eyebrow = ""`; `title = "Task title"`; `subtitle = ""`; `use_large_title = false` | `get_actions_slot()`, `get_progress_slot()`, `get_tabs_slot()`; `ActionsSlot`, `ProgressSlot`, `TabsSlot` | Presents fixed task hierarchy without consuming input. Copy remains visible; slotted actions and tabs use native source-order focus and must provide their own accessible names. |
| `compact_route_heading.tscn` / `VBoxContainer` | `kicker_text = ""`; `title_text = "Route title"`; `detail_text = ""` | No signals or methods | Compact route label, title, supporting detail, and divider for constrained task surfaces. It has no input or navigation behavior; the supplied title is the accessibility name. |
| `section.tscn` / `PanelContainer` | `title = "Section"`; `description = ""` | `get_action_slot()`, `get_body_slot()`; `ActionSlot`, `BodySlot` | Owns one framed inset and stable trailing action lane. Heading and description provide visible context; body and action Controls retain native input and source-order focus. |
| `action_bar.tscn` / `BoxContainer` | `compact_width = 560.0` | `layout_profile_changed(profile)`; `get_leading_slot()`, `get_trailing_slot()`; `LeadingSlot`, `TrailingSlot` | Keeps leading and trailing action groups fixed, then stacks them below the measured threshold. It never duplicates Controls; nested groups preserve source-order focus and accessible labels. |
| `adaptive_toolbar.tscn` / `BoxContainer` | `compact_width = 700.0` | Same API and slots as `ActionBar` | Compose search/count in the leading lane and filters/actions in the trailing lane. Compact reflow retains the same focusable Controls and their accessible state. |

Use one `ResponsiveSplit` instance for both named responsive recipes. For
`stage-content`, keep the bounded stage in `PrimarySlot` and use the default
0.4 ratio. For `task-detail`, set `primary_ratio` to `0.5`. Do not build
separate wide and compact task trees.

`AdaptiveGrid` covers adaptive 2/3/4 layouts by setting `maximum_columns` and a
semantic minimum cell width. Fixed grids remain ordinary native
`GridContainer` nodes.

## Forms and selection

| Scene / root | Public properties and defaults | Signals and methods | Behavior, focus, input, and accessibility |
| --- | --- | --- | --- |
| `text_field.tscn` / `VBoxContainer` | `label_text = "Field label"`; `value = ""`; `placeholder = ""`; `help_text = ""`; `error_text = ""`; `editable = true` | `value_changed(value)`, `value_committed(value)`; `focus_editor()`, `set_error(message)` | Native `LineEdit` input; Return commits. The visible label becomes its accessibility name, help/error becomes the description, and error copy begins with `Error:`. `editable` retains native read-only focus and selection behavior while preventing edits. |
| `text_area.tscn` / `VBoxContainer` | Same defaults as `TextField` | Same signals and methods | Native `TextEdit` with a 112px minimum editor height; focus exit commits. Label/help/error accessibility and native read-only behavior match `TextField`. |
| `search_field.tscn` / `VBoxContainer` | `label_text = "Search"`; `show_label = true`; `value = ""`; `placeholder = "Search"` | `value_changed(value)`, `value_committed(value)`, `cleared`; `focus_editor()`, `clear()` | Icon, editor, and clear action share one visible focus perimeter. Return commits; clear emits `cleared` and returns focus to the editor. The label remains the editor's accessibility name even when visually hidden. |
| `choice_row.tscn` / `Button` | `title = "Choice"`; `description = "Supporting decision copy"`; `action_label = "Select"`; `variant = DETAILED`; native `button_group = null`, `button_pressed = false`, `disabled = false` | `selection_changed(selected)` plus native `pressed` and `toggled`; `set_selected(selected)`, `is_selected()` | The complete native toggle Button is one 44px-minimum target. Title, description, and selected/not-selected state form its accessibility description. Assign a shared `ButtonGroup` for exclusive keyboard/controller selection. |
| `package_choice.tscn` / `Button` | `package_name = "Package"`; `detail_text = ""`; `action_label = "ADD"`; native `button_pressed = false`, `disabled = false` | Native `pressed` and `toggled` | Complete multi-select Package target. The marker, Package identity, detail, and visible `ADD`/`INCLUDED` state form one accessible toggle; callers own Package selection policy and persistence. |
| `package_choice_card.tscn` / `Button` | `package_name = "Package"`; `detail_text = ""`; `action_label = "INCLUDE"`; native `button_pressed = false`, `disabled = false` | Native `pressed` and `toggled` | Detailed multi-select Package card for wide task surfaces. It retains the same one-target selection and accessibility behavior as the compact Package choice. |
| `image_field.tscn` / `VBoxContainer` | `title = "Image"`; `help_text = ""`; `error_text = ""`; `preview = null`; `change_label = "Replace image"`; `disabled = false` | `replace_requested`; `set_preview(texture)`, `set_error(message)` | The native replace Button is the only input target and follows source-order focus. `change_label` is its accessible name, help/error is its description, and the preview is named from `title`. Disabled state prevents focus/activation. The component never opens, admits, or persists a path. |

`SearchField` deliberately supplies one shared focus perimeter for its icon,
native editor, and clear action. `TextField` and `TextArea` keep help or error
copy adjacent to the editor and include that copy in the editor accessibility
description. A `ChoiceRow` is one native toggle-button target; assign a shared
`ButtonGroup` for exclusive selection.

`ImageField` never opens a file or persists an image. Connect
`replace_requested` to consumer- or host-owned admission, which may open the
public `FilePickerDialog`. Call `set_preview()` only after the consumer admits
and loads the selected file; cancel does nothing, and failures use
`set_error()`.

## Dialogs and file selection

| Scene / root | Public properties and defaults | Signals, methods, and slots | Behavior, focus, input, and accessibility |
| --- | --- | --- | --- |
| `dialog.tscn` / `Window` | `tone = INFORMATION`; `eyebrow = "ROOKFRAME"`; `heading = "Dialog title"`; `description = "Explain the decision and its consequence."`; `confirm_label = "Continue"`; `cancel_label = "Cancel"`; `show_cancel = true`; `confirm_enabled = true` | `confirmed`, `cancelled`; `get_body_slot()`, `open_dialog()`, `close_dialog()`; `BodySlot` | Opens as a native modal Window with one blocking scrim and initial focus on the enabled confirmation action. At 600px or narrower it becomes an embedded bottom sheet, retaining the same source-order controls. `ui_cancel`, the cancel action, and `close_requested` emit `cancelled`; an enabled Confirm emits `confirmed`. Visible icon, eyebrow, heading, description, and semantic tone describe the interruption without color alone. |
| `file_picker_dialog.tscn` / `Window` | `heading = "Open a file"`; `description = "Choose a file from your project or computer."`; `initial_directory = "res://"`; `allowed_extensions = []`; `confirm_label = "Open"`; `show_hidden = false` | `file_selected(path)`, `cancelled`, `directory_changed(path)`; `open_picker(directory = "")`, `current_directory()`, `selected_path()` | Initial focus enters Search. Native focusable places, breadcrumbs, file rows, and actions support keyboard/controller navigation; activation opens folders or selects files, `ui_accept` confirms a selection, and `ui_cancel` cancels. Selected name/path and filter summary stay visible and accessible outside hover tooltips. |

`Dialog` is a native modal `Window` with a blocking host scrim, semantic icon
header, bounded message region, optional `BodySlot`, content-driven height,
Escape cancellation, and an initial enabled confirmation focus target. Hosts
set `confirm_enabled = false` while a dynamic validation requirement is unmet;
the native confirmation target then remains visible but unavailable. Its `tone` is one of
`INFORMATION`, `CONFIRMATION`, `DANGER`, or `SUCCESS`; tone changes the visible
icon and semantic accent, never behavior by itself. An acknowledgement exposes
only Confirm; a decision exposes Cancel and Confirm. The header never duplicates
those footer actions with a third close button. It is a decision composition,
not an `AcceptDialog` child-tree wrapper.

`FilePickerDialog` is the designed open-file relationship. It owns navigation
history, places, breadcrumbs, per-folder search, extension filtering, a native
`ItemList` in compact icon-left row mode, selection preview, and explicit
confirmation. Paths are shown in the inspector rather than transient row
tooltips. The host still owns file admission, loading, persistence, and domain
meaning. Do not reach into its internal nodes; configure the documented
properties and consume `file_selected(path)`.

## Feedback and workflow

| Scene / root | Public properties and defaults | Signals, methods, and slots | Behavior, focus, input, and accessibility |
| --- | --- | --- | --- |
| `notice.tscn` / `PanelContainer` | `tone = INFO`; `title = "Notice"`; `description = ""`; `dismissible = false`; tones `INFO`, `PENDING`, `SUCCESS`, `ERROR` | `dismissed`; `get_action_slot()`; `ActionSlot` | Compact in-task status with visible state word and semantic icon. Optional dismiss and slotted actions are native source-order targets; copy remains readable and meaning never depends on color alone. |
| `task_state.tscn` / `PanelContainer` | `state = EMPTY`; `title = "Nothing here yet"`; `description = ""`; states `LOADING`, `EMPTY`, `SUCCESS`, `ERROR` | `get_action_slot()`; `ActionSlot` | Replaces the owning task body; open-ended loading rotates the visible spinner. It consumes no input itself. Recovery/create/continue Controls live in the slot and require native accessible names. State icon, word, title, and description communicate without color alone. |
| `step_progress.tscn` / `VBoxContainer` | `accessible_label = "Workflow progress"`; `steps = ["First step", "Second step"]`; `current_step = 1` (one-based); `compact_width = 720.0`; two to eight steps | `layout_profile_changed(profile)` | Read-only progress: connected complete/current/pending rail when wide and current-step completion card when compact. It never becomes a tab set or focus target. Checks, numbers, current label, position, and one complete accessibility description convey state without color. |

`Notice` and `TaskState` include an icon or shape and a visible state word;
color is supplementary. `StepProgress` uses checks, numbered markers, and a
current-step summary without printing implementation-state words beside every
label. `Notice` stays inside the owning task instead of creating a notification
subsystem. `TaskState` replaces the whole current body while a task is blocked
or terminal; open-ended loading uses a rotating spinner. Bounded numeric
progress remains native `ProgressBar`.

## Structured data display

| Scene / root | Public properties and defaults | Signals, methods, and slots | Behavior, focus, input, and accessibility |
| --- | --- | --- | --- |
| `metric.tscn` / `PanelContainer` | `label_text = "Metric"`; `value_text = "Value"`; `detail_text = ""` | `get_action_slot()`; `ActionSlot` | Read-only label/value/detail hierarchy. Only a slotted native action receives focus; its accessible name must include the local metric context. |
| `metric_strip.tscn` / `GridContainer` | `minimum_columns = 1`; `maximum_columns = 4`; `minimum_column_width = 160.0` | `column_count_changed(column_count)` | Add three or four `Metric` children directly. Equal-priority cells reflow without changing source, reading, or focus order. |
| `icon_action_grid.tscn` / `GridContainer` | `minimum_columns = 1`; `maximum_columns = 2`; `minimum_column_width = 220.0` | `column_count_changed(column_count)` | Add native semantic-icon Buttons directly. The whole 44px-minimum Button remains the target; icon-only actions need matching accessible names and tooltips. Reflow retains source order. |
| `badge.tscn` / `PanelContainer` | `label_text = "Badge"`; `icon = null` | No signals or methods | Read-only short classification. Text remains visible; an optional icon is supplementary and the Badge does not receive focus or behave as a Button. |
| `roll_row.tscn` / `GridContainer` | `state = PENDING`; `ordinal = "1"`; `title = "Roll"`; `detail = ""`; `result = ""`; `die_icon = dice.svg`; `compact_width = 720.0`; states `COMPLETE`, `CURRENT`, `PENDING`, `LOCKED` | `layout_profile_changed(profile)`; `get_action_slot()`; `ActionSlot` | Reflows the same state/ordinal/die/identity/result/action regions. Result stays empty until available. Visible state word and semantic icon communicate state; only the slotted action receives source-order focus. |
| `structured_row.tscn` / `PanelContainer` | `variant = DATA`; `title = "Row identity"`; `detail = ""`; `value_text = ""`; `status_text = ""`; `leading_image = null`; `compact_width = 620.0`; variants `DATA`, `DETAIL`, `COMPACT_DETAIL`, `STACKED_DETAIL`, `SUMMARY`, `TABLE`, `HEADER`, `SELECTION_BANNER`, `CATEGORY`, `CATALOGUE`, `PORTRAIT`, `PENDING` | `layout_profile_changed(profile)`; `get_action_slot()`; `ActionSlot` | Context-neutral read-only row family with one stable trailing lane. Compact reflow retains content and focus order. Title/status remain textual; pending state is not color-only. Use `ChoiceRow`, not this scene, when the entire row must be selectable. |
| `key_value_row.tscn` / `PanelContainer` | `key_text = "Key"`; `value_text = ""` | No signals or methods | Compact read-only fact with a visible key, trailing value, and divider. It receives no input; key and value are combined into its accessibility name and description. |
| `action_row.tscn` / `Button` | `title = "Action"`; `description = "Supporting action detail"`; `action_label = "›"`; `tone = STANDARD`; native `disabled = false`; tones `STANDARD`, `DANGER` | Native `pressed` | Complete native button target for a compact navigation or management action. Title, supporting detail, and trailing action label remain visible; the root uses a secondary or danger semantic action style. Callers own policy and persistence. |
| `package_row.tscn` / `PanelContainer` | `package_name = "Package"`; `detail_text = ""`; `selected = false`; `locked = false`; `locked_state_label = "INCLUDED"` | No signals or methods | Read-only Package identity, role/version detail, marker, and status. `locked` represents an included required Package; application policy and persistence stay outside the component. |
| `package_card.tscn` / `PanelContainer` | Same properties and states as `package_row.tscn`; `locked_state_label = "REQUIRED"` | No signals or methods | Detailed read-only Package card for wide task surfaces. It retains the compact Package row's identity, status, and accessibility behavior. |

The result slot in `RollRow` remains empty before a result exists; do not add
decorative punctuation. The state marker always names its state and uses a
semantic icon. `StructuredRow` exposes a stable `ActionSlot`; selection itself
uses `ChoiceRow` so a non-interactive record does not grow fake button
behavior.

## Managed Surface

| Public type / root | Public properties and defaults | Signals and methods | Behavior, focus, input, and accessibility |
| --- | --- | --- | --- |
| `managed_surface.tscn` / `PanelContainer` | `surface_title = "Managed surface"`; `state = new RookframeManagedSurfaceState` | `placement_changed(placement)`, `minimized`, `restored`, `close_requested`, `lifecycle_changed(snapshot)`; `get_header_slot()`, `get_task_slot()`, `get_footer_slot()`, `set_task(task)`, `open_surface()`, `close_surface()`, `minimize_surface()`, `restore_surface()`, `set_placement(placement)`, `toggle_placement()`, `set_dock_width(width)`, `set_floating_rect(rect)`, `capture_state()`, `restore_state(snapshot)`, `focus_task()` | Chrome controls are native 44px-minimum targets with accessible names/tooltips. One retained task tree keeps its focus state across dock/float and minimize/restore. Header/footer stay fixed; TaskSlot has the only body scroll owner. Close/minimize retain content and emit state instead of owning host policy. |
| `RookframeManagedSurfaceState` / `Resource` | `surface_id = "surface"`; `task_instance_id = "task"`; `placement = DOCKED`; `closed = false`; `minimized = false`; `focused = false`; `dock_width = 560.0`; `floating_rect = Rect2(80, 80, 720, 720)`; `scroll_offset = 0.0` | `state_changed(snapshot)`; `is_visible()`, `placement_name()`, `open_surface()`, `close_surface()`, `minimize_surface()`, `restore_surface()`, `focus_surface()`, `set_placement(next_placement)`, `set_dock_width(value)`, `set_floating_rect(value)`, `set_scroll_offset(value)`, `state_snapshot()`, `restore_snapshot(snapshot)` | Serializable semantic state only; it receives no input and owns no UI. `focus_surface()` records focus only while visible. Snapshot geometry uses numeric `x`, `y`, `width`, and `height` fields so consumer persistence can remain JSON-safe. |

`components/surfaces/managed_surface.tscn` owns exactly four regions:

1. component chrome with presentation, minimize, and close controls;
2. fixed `HeaderSlot`;
3. one `ScrollContainer` and retained `TaskSlot`; and
4. fixed `FooterSlot`.

`set_task(task)` moves one caller-owned Control tree into the body and returns
the previous tree without freeing it. Docking or floating never creates a
second task tree. The host reparents the same Managed Surface scene to its
docked or floating presentation parent when `placement_changed` fires.

`RookframeManagedSurfaceState` is a public Resource type at
`components/surfaces/managed_surface_state.gd`. It serializes semantic
placement, dock width, floating rect, scroll offset, open/minimized state, and
focus state. `capture_state()` and `restore_state()` exchange a Dictionary with
the same fields; floating geometry uses numeric `x`, `y`, `width`, and `height`
members so the snapshot is JSON-safe. A host may store that Dictionary using
its own persistence mechanism. Host registries, stacking/layer policy,
ownership checks, and application placement policy remain excluded.
`focus_surface()` records an
explicit focus transition only while the surface is visible.

Closing and minimizing retain the task tree. `restore_surface()` restores the
last valid task focus when possible, or the first focusable task Control.

## Native-only relationships

No public scene wraps a native Button, checkbox, radio group, numeric input,
slider, list, tree, tab set, menu, popup, ordinary window, grid, separator,
image display, or ordinary progress bar. Use those Controls directly with the
shared Theme and the configuration in
[native controls and recipes](native-controls-and-recipes.md). `Dialog` and
`FilePickerDialog` are public because they own reusable hierarchy and behavior
beyond the adequate built-in nodes; they do not wrap private native child
trees.
