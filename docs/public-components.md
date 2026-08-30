# Public component reference

Every scene and script in this document is public at its normal
`res://rookframe/ui/` path. Scene paths, scene UIDs, script paths, script UIDs,
root types, exported property names and defaults, signals, methods, slot names,
state names, and documented behavior are compatibility contracts within a
SemVer major line.

The machine-readable form of this reference is
`res://rookframe/ui/catalogue.json`.

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

| Scene | Purpose | Public slots and behavior |
| --- | --- | --- |
| `components/layout/adaptive_grid.tscn` | Equal-priority adaptive cells | Direct child Controls; `minimum_columns`, `maximum_columns`, and `minimum_column_width`; emits `column_count_changed` |
| `components/layout/responsive_split.tscn` | `stage-content` and `task-detail` | `PrimarySlot`, `SecondarySlot`; weighted row at wide width, one reading-order column below `compact_width` |
| `components/layout/task_header.tscn` | Fixed task hierarchy | `ActionsSlot`, `ProgressSlot`, `TabsSlot`; exported eyebrow, title, subtitle, and title scale |
| `components/layout/section.tscn` | Framed section and stable trailing lane | `ActionSlot`, `BodySlot`; one content inset owned by the section frame |
| `components/layout/action_bar.tscn` | Fixed leading and trailing action groups | `LeadingSlot`, `TrailingSlot`; source-order focus; stacks the two groups below 560px |
| `components/layout/adaptive_toolbar.tscn` | Search/count plus filter/action groups | Same two slots; 700px default threshold |

Use one `ResponsiveSplit` instance for both named responsive recipes. For
`stage-content`, keep the bounded stage in `PrimarySlot` and use the default
0.4 ratio. For `task-detail`, set `primary_ratio` to `0.5`. Do not build
separate wide and compact task trees.

`AdaptiveGrid` covers adaptive 2/3/4 layouts by setting `maximum_columns` and a
semantic minimum cell width. Fixed grids remain ordinary native
`GridContainer` nodes.

## Forms and selection

| Scene | Public properties | Signals and methods |
| --- | --- | --- |
| `components/forms/text_field.tscn` | `label_text`, `value`, `placeholder`, `help_text`, `error_text`, `editable` | `value_changed`, `value_committed`; `focus_editor()`, `set_error()` |
| `components/forms/text_area.tscn` | Same contract over native `TextEdit` | Commits on focus exit; minimum editor height is 112px |
| `components/forms/search_field.tscn` | `label_text`, `show_label`, `value`, `placeholder` | `value_changed`, `value_committed`, `cleared`; `focus_editor()`, `clear()` |
| `components/forms/choice_row.tscn` | `title`, `description`, `action_label`, `variant`; inherited `button_group`, `button_pressed`, `disabled` | `selection_changed` plus native Button signals; detailed and compact variants |
| `components/forms/image_field.tscn` | `title`, `help_text`, `error_text`, `preview`, `change_label`, `disabled` | `replace_requested`; `set_preview()`, `set_error()` |

`SearchField` deliberately supplies one shared focus perimeter for its icon,
native editor, and clear action. `TextField` and `TextArea` keep help or error
copy adjacent to the editor and include that copy in the editor accessibility
description. A `ChoiceRow` is one native toggle-button target; assign a shared
`ButtonGroup` for exclusive selection.

`ImageField` never opens a file or persists an image. Connect
`replace_requested` to consumer- or host-owned admission. Call `set_preview()`
only after a replacement is ready; cancel does nothing, and failures use
`set_error()`.

## Feedback and workflow

| Scene | States | Public extension |
| --- | --- | --- |
| `components/feedback/notice.tscn` | `INFO`, `PENDING`, `SUCCESS`, `ERROR` | `ActionSlot`, optional dismissal, `dismissed` signal |
| `components/feedback/task_state.tscn` | `LOADING`, `EMPTY`, `SUCCESS`, `ERROR` | Whole-task `ActionSlot` for retry, create, or continue |
| `components/feedback/step_progress.tscn` | complete, current, pending | Two to eight labels, one-based `current_step`, wide/compact profile signal |

Every feedback state includes an icon or shape and a visible state word. Color
is supplementary. `Notice` stays inside the owning task instead of creating a
notification subsystem. `TaskState` replaces the whole current body while a
task is blocked or terminal. Bounded numeric progress remains native
`ProgressBar`.

## Structured data display

| Scene | Contract |
| --- | --- |
| `components/data/metric.tscn` | Label, value, optional detail, and `ActionSlot` |
| `components/data/metric_strip.tscn` | Add three or four `Metric` instances as direct children; equal priority and adaptive columns |
| `components/data/icon_action_grid.tscn` | Add ordinary semantic-icon Buttons directly; maximum two columns |
| `components/data/badge.tscn` | Short classification text with optional semantic icon |
| `components/data/roll_row.tscn` | Six slots: state, ordinal, die, identity, result, action; complete/current/pending/locked |
| `components/data/structured_row.tscn` | One context-neutral family for data, detail, compact detail, stacked detail, summary, table, header, selection banner, category, catalogue, portrait, and pending rows |

The result slot in `RollRow` remains empty before a result exists; do not add
decorative punctuation. The state marker always names its state and uses a
semantic icon. `StructuredRow` exposes a stable `ActionSlot`; selection itself
uses `ChoiceRow` so a non-interactive record does not grow fake button
behavior.

## Managed Surface

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
slider, list, tree, tab set, menu, popup, window, dialog, file dialog, grid,
separator, image display, or ordinary progress bar. Use those Controls directly
with the shared Theme and the configuration in
[native controls and recipes](native-controls-and-recipes.md).
