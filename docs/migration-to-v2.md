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
   theme-specific scene and Theme paths remain compatibility entry points.

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
