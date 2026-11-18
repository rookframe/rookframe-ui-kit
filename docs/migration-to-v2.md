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

## Semantic tokens

These instructions use the procedural rules in [ASD-STE100, Issue 9](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf).
The token names, Theme item names and code identifiers below are technical names.

A semantic token is a named value of a theme.
The UI Kit gives the name of each token.
Each theme gives the value of each token.
All tokens are Theme items of the Theme type `RookframeTokens`.
Colors are `color` items.
Space, shape, elevation, size and motion values are `constant` items.
Each type role is a `font` item and a `font_size` item with the same name.
Each type role also has a `line_spacing_<role>` constant.
`res://rookframe/ui/themes/design_tokens.gd` contains the names of all tokens and their neutral values.
The showcase page "Design tokens" shows each token in the selected theme.
To open this page, run `godot --path showcase -- --component=design_tokens` from the repository root.

1. Use a UI Kit component if a component does the necessary function.

   Use the component as it is.
   Do not override its Theme items.

2. If no component does the function, use a stock Godot control with a UI Kit type variation.

   For example, set `theme_type_variation = &"RookframeMeta"` on a Label.
   Set `theme_type_variation = &"RookframeRaisedSurface"` on a PanelContainer.
   For secondary running text, set `theme_type_variation = &"RookframeBodyMuted"` on a Label.
   This variation has the font, size and line spacing of `RookframeBody` and the `content_muted` color.
   Do not put a `theme_override_colors/font_color` on a `RookframeBody` Label to make it muted.
   This step does not need code.

3. If you must draw a part yourself, read the token in code.

   Use this step for custom drawing, for a StyleBox that you make at runtime, and for a shader value.
   Read the token on the Control that draws the part.

   ```gdscript
   var line := get_theme_color(&"divider", &"RookframeTokens")
   var gap := get_theme_constant(&"space_2", &"RookframeTokens")
   var font := get_theme_font(&"body", &"RookframeTokens")
   var font_size := get_theme_font_size(&"body", &"RookframeTokens")
   ```

4. Read the tokens again when the Control gets `NOTIFICATION_THEME_CHANGED`.

   ```gdscript
   func _notification(what: int) -> void:
   	if what == NOTIFICATION_THEME_CHANGED:
   		_line = get_theme_color(&"divider", &"RookframeTokens")
   		queue_redraw()
   ```

   The host can change the World theme while the World runs.
   This step shows the new theme immediately.
   The UI Kit sets each motion duration to 0 when reduced motion is on.
   Do not read the reduced motion setting of the host.

5. Do not use literal values for appearance.

   Do not write a literal `Color(...)`.
   Do not put a literal pixel size, a literal color or a font resource in a `theme_override_*` property.
   Do not copy a UI Kit style into your Package.

6. If your Package needs its own type variation, get each value of the variation from a token.

   Make the variation in a Theme in code.
   Read each value from a `RookframeTokens` item.
   Make the variation again when the owning Control gets `NOTIFICATION_THEME_CHANGED`.
   Do not use a value that does not come from a token.
   Do not assign this Theme to a Control that contains UI Kit components.
   A nearer Theme stops the theme presentation of the UI Kit components below it.

7. Replace the removed `RookframeUiTokens` constants.

   The Silkbound Ledger script `res://rookframe/ui/tokens.gd` keeps its path, its UID and the class name `RookframeUiTokens`.
   It now contains only the fixed layout breakpoints, because they do not change with the theme.
   All other constants are removed.
   Replace each removed constant with the item in this table.
   Read a token as step 3 shows.

   | Removed constant | Replacement |
   | --- | --- |
   | `COLOR_CANVAS` | `canvas` |
   | `COLOR_SURFACE` | `surface` |
   | `COLOR_SURFACE_RAISED` | `surface_raised` |
   | `COLOR_SURFACE_SUNKEN` | `surface_sunken` |
   | `COLOR_SURFACE_HOVER` | `surface_hover` |
   | `COLOR_SURFACE_ACTIVE`, `COLOR_ACCENT` | `accent` |
   | `COLOR_ACCENT_BRIGHT` | `accent_hover` |
   | `COLOR_INK` | `accent_content` |
   | `COLOR_EDGE` | `border` |
   | `COLOR_RULE` | `divider` |
   | `COLOR_CONTENT` | `content` |
   | `COLOR_CONTENT_MUTED` | `content_muted` |
   | `COLOR_DISABLED` | `content_disabled` |
   | `COLOR_HIERARCHY` | `content_heading` |
   | `COLOR_SUCCESS` | `success` |
   | `COLOR_DANGER` | `danger` |
   | `COLOR_ORNAMENT`, `COLOR_LEDGER_RULE` | `ornament` |
   | `SPACE_1` to `SPACE_8` | `space_1` to `space_8` |
   | `MINIMUM_TARGET_SIZE` | `target_minimum` |
   | `PRIMARY_ACTION_HEIGHT` | `action_height` |
   | `ICON_SIZE` | `icon_medium` |
   | `FOCUS_WIDTH` | `focus_width` |
   | `BORDER_WIDTH` | `border_width` |
   | `RADIUS_SMALL`, `RADIUS_MEDIUM` | `radius_small`, `radius_medium` |
   | `TYPE_TITLE`, `TYPE_SUBTITLE`, `TYPE_HEADING` | `font_size` of `display`, `title`, `heading` |
   | `TYPE_BODY`, `TYPE_LABEL`, `TYPE_VALUE` | `font_size` of `body`, `label`, `value` |
   | `TYPE_INPUT`, `TYPE_ACTION` | `font_size` of `label` |
   | `TYPE_META`, `TYPE_STATUS`, `TYPE_BADGE` | `font_size` of `meta` |
   | `TYPE_IDENTITY` | The `RookframeIdentity` type variation |
   | `LINE_<role>` | `line_spacing_<role>` of the matching type role |
   | `COLOR_RIBBON`, `COLOR_PICTOGRAM`, `COLOR_SECTION_COUNT` | No replacement. These colors belong to the theme. |
   | `FRAME_CUT`, `LEDGER_RULE_WIDTH` | No replacement. The theme StyleBoxes draw frames and rules. |
   | `TEXTAREA_MINIMUM_HEIGHT`, `ADAPTIVE_GRID_MINIMUM_CELL_WIDTH`, `METRIC_MINIMUM_CELL_WIDTH`, `MEDIA_PREVIEW_SIZE`, `INITIAL_DOCK_WIDTH`, `MANAGED_SURFACE_MINIMUM_WIDTH`, `MANAGED_SURFACE_MINIMUM_HEIGHT` | No replacement. Use the UI Kit component that has this size. |

   A `LINE_<role>` constant was a line height.
   A `line_spacing_<role>` constant is the extra space between lines, as in the Label `line_spacing` constant.
   The `RESPONSIVE_*_WIDTH` breakpoints do not change.

8. Make sure that each token has a value where your UI shows.

   If a theme does not give a value for a token, the token has its neutral value.
   The neutral values are in `res://rookframe/ui/themes/neutral_tokens.tres`.
   Each UI Kit theme entry merges these values below its own values.
   If no UI Kit theme entry is on the Control or on a parent, Godot gives empty default values.
   In this condition, set `neutral_tokens.tres` as the project Theme (`gui/theme/custom`).
   You can also merge it into the project Theme.

9. Prepare the local dependencies and import the consumer project.

   ```sh
   python3 tools/workspace.py prepare
   godot --headless --editor --path /path/to/godot-project --import --quit
   ```

10. Check the changed screens in each theme at 1920 × 1080, 1024 × 768, and 844 × 390.

    These components changed their size or look after the base layer was added:

    | Component | Change | Action |
    | --- | --- | --- |
    | `hinged_leaf` | `Surface/Viewport/Root/Skin` fills the leaf at scale 1 and uses `RookframeHingedLeaf`. | If your own template styles `Skin` for the old 2.5 anchors and 0.4 scale, set them in that template. |
    | `TaskTextField`, `TaskTextArea` | `compact` shrinks the gaps and the multiline editor in every theme. | Remove workarounds that set these sizes. |
    | Shared Button with an icon and no text | Side padding is at most `space_4`. | Remove width workarounds. |
    | `RookframeActionRoll` | The token-built variation shows the kit die icon. | Remove a die icon you added to cover the gap. |
    | `IdentityPlate`, `HudBar` | Compact plates keep short names on one line. The bar sizes its identity from the `label` size where the theme has no HUD profile. | Remove font-size and gap workarounds in the identity slot. |
    | `TaskHeader` | Empty Progress and Tabs slots are hidden. | No action. |
    | `ActionRow` | The row grows to the width of its title word and trailing label. | Remove gap workarounds. |
    | Silkbound Ledger `RookframeLabel`, `RookframeMeta`, `RookframeError` | Sizes are 20, 18 and 18 (were 13, 12 and 12). | Check dense Silkbound screens. |
    | Silkbound Ledger `border` token | Copper at 38% opacity (was grey). | If you read `border` and need an opaque color, blend it with the surface behind it. |
    | `PaginatedContent` | A misfit is reported only after the layout has kept its measure for two frames. | Remove code that delays `enabled` until rows settle. |
    | Scenes that inherit a component scene | They take the base scene's presentation. | Remove `presentations` aliases for inheriting scenes. To opt out, give the inheriting scene its own entry. |
    | `ActionRow` | A caller-set `accessibility_name` is kept. | Set the name once; no need to set it again after `title` changes. |
    | `RichTextLabel` | `[b]` and `[i]` use real bold and italic faces in every theme. | Remove font overrides added to make bold visible. Check rich text that relied on bold being regular. |
    | Silkbound Ledger disabled Buttons | `content_disabled` is #788387 and disabled StyleBoxes have a fainter edge; a disabled primary action has no fill. | Remove modulate or opacity workarounds on disabled Buttons. |
