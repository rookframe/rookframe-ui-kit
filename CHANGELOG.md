# Changelog

## Unreleased

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
