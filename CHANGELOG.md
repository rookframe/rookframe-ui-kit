# Changelog

## Unreleased

- `Dialog` dims the background with the `scrim` token in every theme. Its
  scrim was transparent in Fantasy and Cyberpunk, so hosts added their own
  dimming behind it, and that dimming doubled up in Silkbound Ledger, whose
  dialog already read the token. Silkbound Ledger's dialog presentation no
  longer overrides the scrim color. A host whose Theme has no
  `RookframeTokens` gets the neutral `scrim` value. Hosts should drop any
  dimming they place behind a kit dialog.
- Row frames and page ranges follow the rows that are drawn:
  - `Choice` writes its default insets once per variant, density and
    presentation. A refresh for new copy or a Theme notification no longer
    replaces insets its owner set afterwards. In Silkbound Ledger the
    `PaginatedChoices` presentation's 2 px phone insets were replaced by the
    Choice's 9 px a frame after the fit, so rows measured at 44 px drew at
    58 px and the pager cut the second row of a phone list.
  - `PaginatedChoices` fits again when a row's minimum size changes after the
    fit, so page ranges match the rows whichever of the two restyled last.
  - `Choice` applies its inset's anchors again when Theme overrides written in
    sequence leave the inset taller than the row.
  - `Collection` measures each row from its own Controls at the column width,
    as `PaginatedChoices` does, instead of estimating the copy width and line
    heights. In Fantasy and Cyberpunk a wrapped description ran 4 to 49 px
    past its row frame in a narrow column, because the estimate did not match
    the gaps and line heights the Controls resolve there. Silkbound Ledger
    rows keep their heights.
  - `Collection` without a presentation keeps `space_1` between a record's
    content and its frame; the copy touched the frame in Fantasy and Cyberpunk.
- Kit findings from the host HUD redesign:
  - `HudBar` sets the density of tiles a caller groups in plain Containers
    inside its slots, such as one HBoxContainer per tool group. A slot child
    that has `set_compact` still takes it and keeps its own children's density;
    a Container without it is reached into, with any Containers nested in it,
    including tiles added later. The `More` overflow still counts direct slot
    children only.
  - Add the `RookframeTextStack` VBoxContainer variation to the base layer:
    lines that read as one block, such as a heading over its meta line, at a
    `space_1` gap instead of a `separation` override.
  - `PaginatedContent` reports "needs a viewport taller than its indivisible
    content" only after its room, its content's size and its indivisible spans
    have kept their measure for two frames. Rows that report a huge height
    until their wrapped copy has a width, and nested Containers still sorting,
    no longer log. A consumer may enable paging in the frame it adds rows.
  - A scene that inherits a component scene takes that scene's presentation.
    Lookup walks the stock SceneState inheritance chain from the instance's
    `scene_file_path`, nearest first, so a scene with its own `presentations`
    entry keeps it. In Silkbound Ledger the kit's own `AlertDialog`, `Spinner`,
    `Card` and `Item` now take the templates of `Dialog`, `TaskState`, `Section`
    and `StructuredRow`; they previously had those components' hooks only.
  - `ActionRow` keeps an `accessibility_name` its caller set. The title names
    the row only while no other name is set.
  - `RichTextLabel` has real `bold_font`, `italics_font` and
    `bold_italics_font` in every theme; they were the regular face. The base
    layer derives them from the `body` face: its weight axis at 700 (or 200 above
    the body weight), its `ital` or `slnt` axis where it has one, else the
    theme's heavier face of the same family and the synthetic emphasis of
    Godot's default Theme (embolden 1.2, slant 0.2). Fantasy and Cyberpunk get
    Inter at 700 with a synthetic slant. Running text keeps its font and size.
- Silkbound Ledger: disabled Buttons are visibly inactive. `content_disabled`
  is #788387 (was #aebabe, the same as `content_muted`). Button, the
  secondary, primary, wizard, glyph and icon variations and the shared Button
  component take token-bound disabled StyleBoxes with a half-strength edge
  (`border` at 19%, `ledger_edge` at 50%, `ornament` at 20%) and, on the copper
  outlined family, half the fill; a disabled primary action drops its paper
  fill. `RookframePrimaryIcon`, `WizardPrimary`, `WizardQuiet`, `WizardChoice`
  and `WizardSection` icons take `content_disabled` when disabled. Content
  margins match each normal state, so nothing moves.
- Silkbound Ledger: `[b]` is EB Garamond semibold (600) and `[i]` the real
  italic. `[b][i]` shows the italic, because no bold italic is prerendered. The
  Themes now load `italic.res`; a cold deep load is 41.7 MiB (was 31.5, bound 64).

- Close the gaps found while moving MÖRK BORG to the base layer:
  - `hinged_leaf` has a token-built look. Its `Skin` Panel now fills the leaf at
    scale 1 with the new `RookframeHingedLeaf` variation (`surface`, `border`,
    `radius_medium`), and the leaf hands the owning Theme to the skin as well as
    to its content, because Theme lookups stop at its SubViewport. The slab edge
    shown during the swing takes `border`. Silkbound Ledger's leaf is unchanged:
    its presentation now carries the 2.5 anchors and 0.4 scale its leather needs.
    A consumer template that styles `Surface/Viewport/Root/Skin` and relied on
    that scale must set it itself.
  - `TaskTextField` and `TaskTextArea` honour `compact` where no theme presents
    them, through the core default hook `_internal/presentation/defaults/task_field.gd`:
    gaps `space_1` (compact) or `space_2`, single-line editor `target_minimum`,
    multiline editor `action_height + space_3` compact and
    `2 × action_height + space_2` otherwise. The documented `label_font_size`,
    `editor_font_size` and `editor_minimum_height` constant overrides now work
    in every theme.
  - The token-built `RookframeActionRoll` shows the kit's `icons/dice.svg`
    through the Button `icon` Theme item, centred by equal `space_4` insets at
    its natural 56 px width. The base layer may now load a kit pictogram from
    `res://rookframe/ui/icons/`; `tests/test_workspace.py` still forbids colors,
    fonts and materials.
  - An icon-only shared Button keeps at most `space_4` beside its icon, so it is
    56 px wide in Fantasy (was 96) and 52–60 px in Cyberpunk (was 68–70).
    `Button.is_icon_only()` is public; a presentation that replaces the faces
    fits them itself, as Fantasy's carved Button now does.
  - A compact `IdentityPlate` wraps at no less than 7.5 em of its title size, so
    a theme's fixed `copy_width` no longer breaks a short name (Fantasy: one line
    instead of two for both the name and the detail).
  - `HudBar` scopes a token-built profile Theme to its identity slot where the
    owning Theme's presentation supplies none: `RookframeIdentity` and
    `RookframeValue` at the `label` size and `space_1` between lines. Cyberpunk's
    compact bar drops from 160 to 121 px. Silkbound Ledger and Fantasy keep their
    own profiles. With no tokens in the tree the bar assigns no Theme.
  - `TaskHeader` hides its Progress and Tabs slots while they hold nothing visible.
  - `PaginatedContent` measures again one frame later before it reports content
    taller than its viewport, so a layout still settling after a resize no longer logs.
  - `ActionRow` keeps the widest word of its title, the gap and the trailing
    label inside its width, so a narrow row no longer runs "HP" into "15 / 15".
    A caller's `custom_minimum_size.x` remains the floor.
- Silkbound Ledger: `RookframeLabel` (13 -> 20), `RookframeMeta` (12 -> 18) and
  `RookframeError` (12 -> 18) now follow the `label` and `meta` size tokens, like
  `RookframeStatus`, `RookframePending` and `RookframeSuccess`. The tokens were
  already what the theme's controls, status roles and refined presentations
  use; the three variations were the dense fallback of the task/sheet profile.
  Captions and field labels that showed that fallback grow; review dense
  Silkbound screens.
- Silkbound Ledger: `border` is the copper its controls are outlined in
  (`ornament` at 38%, was grey #5b6265), so token-built and Package outlines
  match Button, LineEdit, TextEdit and OptionButton. Authored panels, cards,
  popups and shell controls keep their grey edge through the theme-private
  `ledger_edge` primitive. `border_strong` already matched selected outlines.

- Text must stay readable on interactive fills: `AA_PAIRS` adds `content` and
  `content_muted` on `surface_hover`, `surface_pressed` and `accent_subtle`.
  Neutral set: `content_muted` #a0a0a0 -> #a8a8a8, `surface_hover` #404040 ->
  #3c3c3c, `surface_pressed` #4a4a4a -> #303030 (pressed now sinks below
  raised), `danger` #e06c6c -> #e47474. Fantasy: `content_muted`
  (0.69, 0.65, 0.555) -> (0.7, 0.66, 0.565), `surface_hover` #394337 -> #373f35,
  `accent_subtle` #4c452b -> #443d27. The base layer's destructive hover and
  pressed fills mix 10% and 16% of `danger` (was 16% and 30%), so
  `danger_content` stays at AA where a theme inks it in `danger`;
  `ui-kit/tests/token_base.gd` checks every text ink the layer builds.
- Silkbound Ledger: `surface_hover` (#3c464b), `surface_pressed` (#2c3337) and
  `accent_subtle` (#3d413f, `surface` with 15% paper) are now distinct from
  `surface_raised`, for the base layer and Package token reads. Authored
  Silkbound controls keep their look: their bindings name the theme-private
  `ledger_hover`, `ledger_pressed` and `ledger_selected` fill (#343d41).
- Add the `RookframeBodyMuted` Label variation to the base layer: the body
  face, size and line spacing in `content_muted`, for secondary running text.

- Add the token-built base layer `themes/token_base.gd`. Every component theme
  entry generates the standard stock controls and kit type variations
  (`Rookframe*`, `Task*`, `Wizard*`, `components_button*`) from its own
  `RookframeTokens` and lays them beneath its sources, so Package and host UI is
  complete in any theme. A type a theme defines stays that theme's alone.
  Fantasy and Cyberpunk gain every control and variation they did not author;
  Silkbound Ledger gains only `FoldableContainer` (Accordion, Collapsible),
  `LinkButton`, `MenuBar`, the `ScrollContainer` focus ring, `RookframePopover`
  and the `RookframeInlineNotice*` states. An entry without a default font uses
  the `body` role. The layer also spaces `HBoxContainer`, `VBoxContainer`, flow
  and grid containers on `space_3`/`space_4` and bounds Button icons to
  `icon_medium`, so Fantasy and Cyberpunk layouts gain the gaps Silkbound Ledger
  authors. `ui-kit/tests/token_base.gd` checks coverage and ownership.
- ActionRow grows to hold copy that outgrows its authored height.
- Give the full-screen wizard a theme-independent responsive fit: where the
  owning Theme has no presentation hook, a core default hook
  (`_internal/presentation/defaults/fullscreen_wizard.gd`) sizes the header,
  steps and footer from tokens, folds the step names into the header on short
  viewports, bounds action icons to `icon_medium`, keeps actions at
  `target_minimum` and marks pending, current and completed steps. Silkbound
  Ledger keeps its own hook.
- Carry the owning Theme to the Action Panel emblem, which sits beneath a
  Node2D where native Theme inheritance stops; unskinned themes now style it.
- Silkbound Ledger: the Action Panel profile Theme no longer defines the base
  `Label` color, which replaced the `Rookframe*` label variations of slot
  content. Plain labels are unchanged; `RookframeMeta`, `RookframeStatus`,
  `RookframeSuccess`, `RookframeError` and the like now show their own ink there.
- Declare the semantic token contract: Theme type `RookframeTokens` with color,
  type, space, shape, elevation, size and motion items, listed by item type in
  `themes/design_tokens.gd`. The core ships the neutral set
  `themes/neutral_tokens.tres`; every component theme entry merges it beneath
  its own sources, so a token a theme omits resolves to its neutral default.
  `ui-kit/tests/design_tokens.gd` checks completeness and WCAG AA pairs.
- Fix PaginatedChoices pages that held one or two rows in a tall column: rows
  on hidden pages are now measured at the column width instead of their stale
  layout, and every row gets the measured page height. A configure repeated
  before the deferred fit keeps revealing a changed selection, and a resize or
  theme change keeps the selection (or the page's first entry) on screen.
- Define every semantic token in Silkbound Ledger from one source,
  `theme/silkbound_tokens.gd`, supplied to the canonical Theme as a supplemental
  token set. Its Themes and presentation scenes name the token behind each role
  value in `metadata/tokens`; `tools/apply-silkbound-tokens.gd` writes the token
  values into them and checks for drift, and presentation scripts read the same
  source. The appearance is unchanged.
- Define every semantic token in Fantasy (`themes/fantasy/tokens.gd`) and
  Cyberpunk (`menu/cyberpunk/materials/cyberpunk_tokens.gd`). Their `Rookframe*`
  type variations and role-bearing material values read the token source.
  Fantasy `RookframeTitle` and `RookframeSubtitle` now use the display face.
- Retire the Silkbound Ledger `RookframeUiTokens` constants (`rookframe/ui/tokens.gd`):
  only the fixed `RESPONSIVE_*_WIDTH` layout breakpoints remain, at the same path
  and UID. Read the semantic token instead; `docs/migration-to-v2.md` maps each
  removed constant. The legacy showcase catalogue was the only reader.
- Add the showcase page Design tokens (`--component=design_tokens`) in a new
  Foundations group. It lists every `RookframeTokens` item of the selected theme
  from `design_tokens.gd` and updates in place on a theme change;
  `showcase/tests/token_reference.gd` checks and captures it in every theme.
- Document how Packages use tokens in `docs/migration-to-v2.md`.

- Add the in-place radial choice to the unthemed core: `navigation/arc_track.tscn`
  places Controls along a scrollable arc over a drawn rail, and
  `navigation/arc_picker.tscn` composes category and previewed item tracks with a
  caption hub, keyboard/wheel/pointer input and on-screen fitting. Previews may
  mix flat swatches and rendered tiles. Showcase page `arc_picker` and
  `showcase/tests/arc_picker.gd` exercise it under every preview Theme.
- Style ArcTrack and ArcPicker in every optional theme: carved brass medallions
  with iron and brass rails in Fantasy, ink and paper medallions on a copper
  ledger rule in Silkbound Ledger (canonical Theme only, through a supplemental
  profile), and neon glass medallions on a cyan trace in Cyberpunk.

- Add HUD building blocks to the unthemed core: `layout/hud_bar.tscn` with
  compact overflow, `data/identity_plate.tscn`, `data/vital_meter.tscn`, the
  `forms/favorite_toggle.tscn` native proxy, and the Button `EMBLEM` variant and
  `layout = STACKED` axis for HUD tiles (`components_button_emblem`, `__stacked`).
  Document component boundaries and variation-name axes in the design contract.
  Silkbound Ledger, Fantasy and Cyberpunk map every new HUD and Button variation.

- Add the shared Chronicle surface for retained event histories, recaps, quest
  journals and lore: a lightly worn paper scroll in Fantasy and an archive panel
  in Cyberpunk, with reading styles, compact density and catalogue guidance.
- Preserve Fantasy Chronicle rolls and paper grain when resizing vertically:
  repeat the reading field and edge wear with a soft join into the bottom roll.

- Migrate the shared default and task Themes, tokens, forms, records, progress,
  and managed/file-picker surfaces to Silkbound Ledger using stock Godot.
- Complete native control states and regional serif font resources; retain all
  legacy public font/frame paths.
- Remove design-system opt-in from common task components, reconcile catalogue
  coverage, and make notepad pagination use the editor's full native line box.

- Document optional Catalogue search, exact release details, pagination and
  accountless acquisition composition with existing native controls. No public
  resource, Theme token, candidate tag or SDK boundary changes.


This repository follows independent UI Kit SemVer. Stable v1.0.0 has not been
published.

## v1.0.0-rc.1 candidate

### Added

- RFG-304: collision, light-on and light-off semantic roles from pinned Tabler
  3.46.0, seven attributed Game-icons.net domain pictograms, and native icon
  tinting for existing managed-control and danger-outline Theme roles. Public
  resource paths and catalogue entries remain additive.

- Public shell and managed-task Theme roles, with catalogue examples and native
  focus/disabled states, for the unchanged approved Tabletop composition.
- Search Field density and persistent-clear options for managed tasks.
- Shared circular icon actions and compact outlined task actions, including
  touch density, normal/hover/pressed/disabled states and visible focus, for
  the approved RFG-177 contribution composition.

- Complete native Godot Theme coverage for windows/dialogs, tabs, lists,
  trees, ranges, choices, menus, flow/grid containers, and state families.
- Public editor-authored scenes for the inventory-backed layout, form/search,
  feedback, managed-surface, and structured-data relationships Godot does not
  provide as one built-in node.
- Serializable Managed Surface placement, geometry, scroll, focus, and
  open/minimized state without host registry or application policy.
- Human-readable and machine-readable public API references.
- A complete visual catalogue for native controls, forms, responsive layout,
  feedback, structured data, all 62 semantic icons, and Managed Surface
  behavior.
- Pinned upstream drawings for every semantic icon role.
- Complete public identity, component, semantic icon, native composition,
  accessibility/input, compatibility, licensing, attribution, and migration
  documentation.
- A reviewed clean-project gd-plug consumer that configures, styles, and
  connects public resources through ordinary Godot authoring.

### Fixed

- Approved display/UI font weights and context-appropriate clear/minimize
  drawings now ship in the public dependency, making clean consumers match
  the existing reference appearance.
- Image Field forwards visible help or error copy to the replace action's
  accessibility description.

### Compatibility

The UI Kit uses SemVer, not SDK Editions. Exact authoring UI Kit version and
commit metadata are provenance rather than a runtime dependency contract. A
Package declares compatible Rookframe Versions, and the selected Rookframe
Version supplies its compatible UI Kit before Package scenes load. Direct
Godot API and format use remains outside Rookframe's backwards-compatibility
guarantee.

The annotated pre-user `v1.0.0-rc.1` candidate tag identifies one exact commit
at a time and may be updated by the owner while there are no external users.
Consumers still pin the full commit. Stable `v1.0.0` remains unpublished.
