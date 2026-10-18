# Migration to v2

Version 2 separates core components, themes, and shared theme dependencies.
This change removes the old component paths and properties. There are no compatibility aliases.

1. Install the required packages from the repository root.

   ```sh
   python3 tools/workspace.py install --destination /path/to/godot-project
   ```

   If you need a theme, add `--theme silkbound-ledger`, `--theme fantasy`, or `--theme cyberpunk`.
   The core components use Godot defaults.
   Keep using `res://rookframe/ui/components/` for every theme. Assign
   `res://rookframe/ui/themes/<theme-name>/theme.tres` to the parent Control.
   This activates both native styles and richer component presentation. Existing
   theme-specific paths remain available except for the selection resources listed below.

2. Replace the component paths in scenes and scripts with the paths in this table.

   The paths are relative to `res://rookframe/ui/components/`.
   For Silkbound Ledger scenes, make the same changes after its `components/` prefix.
   For `.gd` references, use the new file name with the `.gd` extension.

   | Old path | New path |
   | --- | --- |
   | `data/silkbound_collection.tscn` | `data/collection.tscn` |
   | `content/silkbound_miniature_browser.tscn` | `content/miniature_picker.tscn` |
   | `feedback/silkbound_tooltip.tscn` | `feedback/record_tooltip.tscn` |

   If you use the default root node names in NodePaths, replace these names.

   | Old name | New name |
   | --- | --- |
   | `SilkboundCollection` | `Collection` |
   | `SilkboundMiniatureBrowser` | `MiniaturePicker` |
   | `SilkboundTooltip` | `RecordTooltip` |

3. Remove `silkbound` property assignments from core components.

   For Silkbound Ledger `PaginatedContent`, replace `silkbound` with `decorated_pager`.
   For Silkbound Ledger `PaginatedChoices`, replace `silkbound` with `spaced_range`.
   Keep the existing Boolean value.
   For `SummaryBlock`, `TaskTextField`, and `TaskTextArea`, remove the assignment.

4. Replace these variation names in custom Themes, scenes, and scripts.

   For a name with `*`, keep the text after the prefix.

   | Old name | New name |
   | --- | --- |
   | `SilkIcon` | `RookframeIcon` |
   | `SilkPrimaryIcon` | `RookframePrimaryIcon` |
   | `SilkNotice*` | `RookframeInlineNotice*` |
   | `SilkDialogSurface` | `RookframeModalSurface` |
   | `SilkDialogBody` | `RookframeDialogBody` |
   | `SilkDialogCopy` | `RookframeDialogCopy` |
   | `SilkDialogFooter` | `RookframeDialogFooter` |
   | `SilkDialogMessage` | `RookframeDialogMessage` |
   | `SilkDialogTitle` | `RookframeDialogTitle` |
   | `SilkCreatureClassificationTablet` | `RookframeCreatureClassificationTablet` |
   | `SilkCreatureDialogAmountDesktop` | `RookframeCreatureDialogAmountDesktop` |

5. If your code reads the core catalogue, remove these theme registry lookups.

   - `optionalThemes`
   - `currentDesignSystem.optionalThemePackages`

   Read theme-specific data from the selected theme package.

6. If your tools use source folder paths, replace these paths.

   | Old path | New path |
   | --- | --- |
   | `themes/fonts/` | `shared/fonts/` |
   | `themes/shell-common/` | `shared/shell-common/` |
   | `ui-kit/tests/` theme integration suites | `showcase/tests/theme_components/` |

   The font and shell resource paths in Godot do not change.
   Core component checks remain in `ui-kit/tests/`.

7. Prepare the showcase after changes to package sources.

   ```sh
   python3 tools/workspace.py prepare
   ```

8. Import the consumer project in Godot.

   ```sh
   godot --headless --editor --path /path/to/godot-project --import --quit
   ```

   Check the changed screens at their supported viewport sizes.

## Selection components

These instructions use the procedural rules in [ASD-STE100, Issue 9](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf).
The resource names and code identifiers below are technical names.
Version 2 removes the old selection resources and their UIDs.
There are no aliases for these resources.

1. Replace each old resource path with the new path in the table.

   All paths in this table start at `res://rookframe/ui/`.

   | Old path | New path |
   | --- | --- |
   | `components/forms/choice_row.tscn` | `components/forms/choice.tscn` |
   | `components/forms/package_choice.tscn` | `components/forms/choice.tscn` |
   | `components/forms/package_choice_card.tscn` | `components/forms/choice.tscn` |
   | `menu/Switch.tscn` | `components/forms/choice.tscn` |
   | `_internal/data/task_choice.tscn` | `components/forms/choice.tscn` |
   | `menu/SwitchGroup.tscn` | `components/forms/choice_group.tscn` |
   | `menu/MenuChoice.tscn` | `components/forms/select.tscn` |
   | `components/forms/radio_group.tres` | `components/forms/selection_group.tres` |
   | `components/actions/toggle_group.tres` | `components/forms/selection_group.tres` |

2. Replace old Silkbound Ledger selection scene paths with the core paths from step 1.

   The old paths start with `res://rookframe/ui/silkbound-ledger/`.
   The core scenes use the Theme on their parent Control.

3. Remove old UID references for the resources in step 1.

4. Replace direct script references with the corresponding new script path.

   | Old script | New script |
   | --- | --- |
   | `components/forms/choice_row.gd` | `components/forms/choice.gd` |
   | `components/forms/package_choice.gd` | `components/forms/choice.gd` |
   | `menu/switch.gd` | `components/forms/choice.gd` |
   | `menu/switch_group.gd` | `components/forms/choice_group.gd` |
   | `menu/menu_choice.gd` | `components/forms/select.gd` |

5. Set the Choice properties for each previous presentation.

   | Previous presentation | New Choice properties |
   | --- | --- |
   | Detailed Choice Row | `variant = ROW` |
   | Compact Choice Row | `variant = ROW`, `compact = true`, `show_description = false` |
   | Switch card | `variant = CARD` |
   | Package Choice | `variant = MARKED_ROW`, `action_label = "ADD"`, `selected_label = "Included"` |
   | Package Choice Card | `variant = MARKED_CARD`, `action_label = "INCLUDE"`, `selected_label = "Included"` |
   | TaskChoice | `variant = LIST` |

   The Choice variant values are `ROW = 0`, `CARD = 1`, `MARKED_ROW = 2`, `MARKED_CARD = 3`, and `LIST = 4`.
   The old compact Choice Row value `1` now means `CARD`.
   The `compact` property does not hide the description.

6. Replace the Package Choice property names.

   | Old property | New property |
   | --- | --- |
   | `package_name` | `title` |
   | `detail_text` | `description` |

7. Use `leading_icon`, `marker_text`, and `value_text` for optional Choice content.

8. Replace direct writes to the old TaskChoice child nodes with Choice property assignments.

   | Old child property | Choice property |
   | --- | --- |
   | `Inset/Row/Copy/Title.text` | `title` |
   | `Inset/Row/Copy/Subtitle.text` | `description` |
   | `Inset/Row/Icon.texture` | `leading_icon` |
   | `Inset/Row/Value.text` | `value_text` |

   The shared child paths start with `Content/Row/`.
   The supporting Label has the name `Description`.
   Paginated Choices sets `variant = LIST` on each row.

9. If you supply `row_scene` to Paginated Choices, use a scene that inherits Choice.

10. Set `variant = MENU` on each Select that replaces MenuChoice.

    The Select variant values are `NATIVE = 0` and `MENU = 1`.
    The existing Select path uses `NATIVE` by default.
    Native item IDs, selection signals, and search remain available.
    The menu variant retains density, selection marks, and popup placement.

11. Add group options to the container from `ChoiceGroup.get_options()`.

12. For exclusive selection, assign one shared `ButtonGroup` to the options.

13. Set one enabled option to `button_pressed = true` when the group requires an initial selection.

14. If the user can clear the selection, set `ButtonGroup.allow_unpress = true`.

15. For independent choices, remove the `button_group` assignment.

16. Use a separate `ButtonGroup` resource for each independent group.

    Choice Group controls layout and density.
    Choice Group does not control selection.
    The native `pressed` and `toggled` signals remain available on Choice.
    The Choice `selection_changed` signal reports the same state as `toggled`.

17. Update custom presentation templates to use the new paths and shared Choice child names.

    The existing `components_switch`, `components_switch_group`, and `components_switch_options` Theme variations remain available.
    The existing `settings_choice` and `settings_popup` Theme variations remain available for the Select menu variant.

18. Prepare the local dependencies after the source changes.

    ```sh
    python3 tools/workspace.py prepare
    ```

19. Import the consumer project in Godot to create its resource references.

    ```sh
    godot --headless --editor --path /path/to/godot-project --import --quit
    ```

20. Check selection, disabled states, keyboard focus, and popup behavior on the changed screens.

21. Check the changed screens at 1920 × 1080, 1024 × 768, and 844 × 390.
