# RFG-161 completion coverage

This maps every RFG-160 role assigned to RFG-161 to its public implementation
and visual-catalogue evidence. Roles delivered by native Godot remain native;
the table does not convert them into wrapper scenes.

## Native Godot plus Rookframe Theme

| Inventory role | Delivery | Catalogue evidence |
| --- | --- | --- |
| Windows, dialogs, confirmations, file dialogs, popup placement | `Window`, `AcceptDialog`, `ConfirmationDialog`, `FileDialog`, and Popup Theme coverage plus native recipe | Native tab; interactive overlay buttons |
| Numeric input, ranges, sliders, and spin controls | `SpinBox`, `HSlider`, and `VSlider` Theme coverage | Native tab |
| Dense list, tree, and item selection | `ItemList` and `Tree` Theme coverage | Native tab, selected/disabled records |
| Disabled, hover, pressed, selected, pending, empty, loading, success, error | Native Theme states plus semantic component states | Every catalogue tab |
| Native menus, popup actions, and context behavior | `MenuButton`, `OptionButton`, `PopupMenu`, `PopupPanel`; documented focus/dismissal recipe | Native tab |
| Native tabs, grids, inputs, progress, scrolling, separators, images | Direct built-in Controls and Containers | Native tab and every composition tab |

## Missing reusable relationships

| Inventory role | Public delivery | Catalogue evidence |
| --- | --- | --- |
| Managed Surface fixed header, one scrolling body, fixed footer | `managed_surface.tscn` | Managed tab |
| Placement, docking/floating restoration, focus, retained task | `managed_surface.gd` and `managed_surface_state.gd`; host registries excluded | Managed tab |
| Task header | `task_header.tscn` | Managed tab |
| Leading/trailing Action Bar | `action_bar.tscn` | Layout and Managed tabs |
| Responsive stage-content and task-detail | `responsive_split.tscn` with semantic ratio configuration | Layout tab |
| Form stack | Native `VBoxContainer` recipe | Forms tab |
| Field label/help/error adjacency | `text_field.tscn`, `text_area.tscn` | Forms tab, help and error |
| One-perimeter Search Field | `search_field.tscn` | Forms and Layout tabs |
| Adaptive toolbar | `adaptive_toolbar.tscn` | Layout tab |
| Section header with stable trailing lane | `section.tscn` | Layout tab |
| Two-column icon action grid | `icon_action_grid.tscn` plus native Buttons | Layout tab |
| Full/compact workflow progress | `step_progress.tscn` | Feedback tab, full and 520px constrained examples |
| Equal metric strip and cells | `metric_strip.tscn`, `metric.tscn` | Data tab |
| Roll/result row and four markers | `roll_row.tscn` | Data tab, complete/current/pending/locked |
| Whole-task lifecycle region | `task_state.tscn` | Feedback tab, all four states |
| Compact semantic Notice | `notice.tscn` | Feedback tab, all four tones |
| Detailed and compact Choice Row | `choice_row.tscn` | Forms tab, selected/compact/disabled |
| Category and summary rows | `structured_row.tscn` variants | Data tab |
| Data, detail, compact-detail, stacked-detail, table rows | `structured_row.tscn` variants | Data tab |
| Header, selection-banner, catalogue, portrait, pending subrows | `structured_row.tscn` variants | Data tab |
| Classification badge | `badge.tscn`; native themed frame plus semantic icon/text | Data tab |
| Adaptive content/section stacks and summary regions | Native containers, `adaptive_grid.tscn`, `responsive_split.tscn`, and documented recipes | Layout and Data tabs |
| Semantic image replacement field | `image_field.tscn`; host/consumer admission and persistence excluded | Forms tab |

## Semantic assets and public contracts

- The existing 62-role semantic icon manifest remains complete and contains no
  Manager-, Character Sheet-, or Package-named alias.
- `res://rookframe/ui/catalogue.json` records Theme variation names, native
  types, every public scene/script UID, root type, property/default, signal,
  method, slot, variant, and supported state.
- [Public component reference](public-components.md),
  [native recipes](native-controls-and-recipes.md), and
  [accessibility/input](accessibility-and-input.md) define supported use and
  behavior.

## Exclusions retained

The public tree contains no application screen, route, workflow, domain state,
host registry, Package adapter, consumer-specific duplicate, redundant native
wrapper, or C# widget hierarchy. Managed Surface does not own the host's
registry, presentation layers, persistence backend, ownership checks, or
placement policy. Image Field does not own filesystem access or domain
persistence.

No automated validation suite, scripted release gate, SDK Edition relation, or
stable v1.0.0 publication was added.
