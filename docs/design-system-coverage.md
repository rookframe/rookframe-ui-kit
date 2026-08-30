# Design-system coverage inventory

This is the reviewed RFG-160 inventory and the input contract for RFG-161. It
classifies every reusable 2D visual, layout, and interaction role found in:

- old Bevy Rookframe at commit
  `1230e73777ee0fa2f4e17ec8c804e0c4061465de`, especially the checked-in
  design-system README, component catalogue, coverage matrix, layout recipes,
  token source, semantic icon manifest, and runnable UI Kit showcase; and
- current Godot Rookframe at commit
  `440476774a967a22a9ab2a27f3bf8077da162489`, especially
  `rookframe/ui/`, the shared Theme, static factories, Managed Surface state,
  Package presentation adapter, and Tabletop Workspace.

Unrelated local working-tree changes in those repositories were excluded. The
old running Rookframe/design-system material is visual authority; current Godot
files are implementation and migration evidence, not proof of completeness.

RFG-161's delivery against this unchanged inventory is recorded separately in
[the completion coverage map](rfg-161-coverage.md).

## Classification

- **Native + Theme**: Godot owns the behavior. The kit supplies Theme coverage,
  semantic assets, and configuration/composition guidance without a wrapper.
- **Kit relationship**: Godot lacks a cohesive cross-Package relationship. A
  later slice may add an editor-authored public scene and only the small script
  required by that relationship.
- **Application-specific**: a finished screen, workflow, domain concern, host
  registry/orchestration responsibility, or rendered tabletop capability. It
  is intentionally excluded rather than copied.

`Foundation` means RFG-160 establishes the role. `RFG-161` means this inventory
requires its implementation in the completion slice. `Excluded` means no UI
Kit implementation is permitted without a later product decision.

## Foundation and native roles

| Reusable role | Evidence normalized | Classification | Delivery |
| --- | --- | --- | --- |
| Semantic palette | Bevy token palette; Godot Theme and Manager color helpers | Native + Theme | Foundation |
| Inter readable-copy typography | Bevy text roles; Godot default and Manager fonts | Native + Theme | Foundation |
| Exo 2 managed hierarchy typography | Bevy title/heading roles; Godot display labels | Native + Theme | Foundation |
| 4px spatial rhythm and named spacing | Bevy layout tokens; Godot repeated 4/8/12/16/24 insets | Native + Theme | Foundation |
| Minimum target, border, radius, and frame geometry | Bevy control tokens; Godot 44/52px control factories | Native + Theme | Foundation |
| Visible keyboard/controller focus | Bevy focus frame; Godot focused input/button styles | Native + Theme | Foundation |
| Canvas, surface, raised, inset, section, notice, and managed frames | Bevy frame assets; Godot panel variations | Native + Theme | Foundation |
| General semantic icon registry | Bevy 62-role manifest; Godot generic SVG subset | Native + Theme | Foundation |
| Title, subtitle, heading, label, value, body, meta, status, success, error, identity, and badge text | Bevy text catalogue; many Godot Manager/managed label aliases | Native + Theme | Foundation |
| Primary, secondary, quiet, danger, and tab actions | Bevy action hierarchy; Godot semantic Button variations | Native + Theme | Foundation |
| Single-line text input | Bevy `TextField`; Godot `LineEdit` | Native + Theme | Foundation |
| Multiline text input | Bevy `TextArea`; Godot had no complete shared role | Native + Theme | Foundation |
| Boolean and exclusive choices | Bevy `Checkbox`/`Radio`; Godot built-ins | Native + Theme | Foundation |
| Menu buttons, option selection, popup actions | Bevy context/action menus; Godot `MenuButton`, `OptionButton`, `PopupMenu` | Native + Theme | Foundation |
| Bounded progress | Bevy `Progress`; Godot `ProgressBar` | Native + Theme | Foundation |
| Tabs with one loaded panel set | Bevy local Tabs contract; Godot `TabBar`/`TabContainer` | Native + Theme | Foundation |
| Column, row, grid, split, margin, center, and aspect layout | Bevy primitive layouts; Godot Containers | Native + Theme | Foundation |
| Body scrolling and scrollbars | Bevy one-scroll-owner rule; Godot `ScrollContainer` | Native + Theme | Foundation |
| Rules and separators | Bevy ruled rows/sections; Godot separators | Native + Theme | Foundation |
| Bounded image display | Bevy Image; Godot `TextureRect` | Native + Theme | Foundation |
| Ordinary windows and popup placement | Bevy overlay placement; Godot `Window` and Popup behavior | Native + Theme | RFG-161 |
| Numeric input, ranges, sliders, and spin controls | Bevy field/control inventory; Godot built-ins | Native + Theme | RFG-161 |
| Dense list, tree, and item selection | Bevy list/table catalogue; current Godot dynamic rows | Native + Theme | RFG-161 |
| Native disabled, hover, pressed, selected, empty, pending, success, and error states | Both implementations' state families | Native + Theme | RFG-161 |

## Missing reusable relationships

| Reusable role | Evidence normalized | Classification | Delivery |
| --- | --- | --- | --- |
| Managed Surface anatomy: fixed task header, one scrolling body, fixed footer | Bevy managed-surface contract; Godot static factory | Kit relationship | RFG-161 |
| Designed acknowledgement and confirmed-decision dialog | Bevy overlay hierarchy; Godot built-ins lack the Rookframe visual/content relationship | Kit relationship over native `Window` behavior | RFG-161 |
| Designed open-file browser | Bevy file task hierarchy; Godot `FileDialog` lacks the Rookframe places/preview composition | Kit relationship over native filesystem and selection Controls | RFG-161 |
| Managed placement, docking/floating restoration, focus, and one retained task tree | Bevy host relationship; Godot `managed_surface_state.gd` | Kit relationship, with host registries excluded | RFG-161 |
| Task header composition | Bevy `TaskHeader`; current Godot chrome/title factories | Kit relationship | RFG-161 |
| Action bar with arbitrary leading/trailing groups and source-order focus | Bevy `ActionBar`; Godot managed footer | Kit relationship | RFG-161 |
| Responsive `stage-content` relationship | Bevy wide rail/compact progress recipe | Kit relationship | RFG-161 |
| Responsive `task-detail` relationship | Bevy balanced detail/stacked reading recipe | Kit relationship | RFG-161 |
| `form-stack` relationship | Bevy form recipe; repeated Godot field construction | Kit relationship | RFG-161 |
| Field label, help, and error adjacency | Bevy `TextField` contract; Godot field/error label aliases | Kit relationship | RFG-161 |
| Search field with one focus perimeter, icon, editor, and clear action | Bevy `SearchField`; current Godot search rows | Kit relationship | RFG-161 |
| Adaptive toolbar with search, count, filters, and actions | Bevy actor/adversary catalogue; Godot library toolbars | Kit relationship | RFG-161 |
| Section header with stable trailing action lane | Bevy `Section`; Godot managed section | Kit relationship | RFG-161 |
| Two-column semantic icon action grid | Bevy `IconActionGrid`; Godot action compositions | Kit relationship | RFG-161 |
| Full/compact workflow step progress | Bevy `StepProgress`; no complete Godot relationship | Kit relationship | RFG-161 |
| Equal metric strip and cells | Bevy character facts; Godot statistic rows | Kit relationship | RFG-161 |
| Roll/result row and complete/current/pending/locked marker | Bevy `RollRow`; current Godot action rows | Kit relationship | RFG-161 |
| Whole-task loading, empty, recovery, and terminal state region | Bevy `TaskState`; current Godot modal/notice handling | Kit relationship | RFG-161 |
| Compact notice with semantic state, wrapping copy, actions, and dismissal | Bevy `Notice`; Godot notice factory | Kit relationship | RFG-161 |
| Detailed and compact single-select Choice Row | Bevy `ChoiceRow`; current Godot selectable rows | Kit relationship | RFG-161 |
| Category and summary rows with stable trailing lane | Bevy Selected-Rook and summary rows; Godot selected-Rook rows | Kit relationship after removing Rook domain naming | RFG-161 |
| Data, detail, compact-detail, stacked-detail, and table rows | Bevy structured row catalogue; Godot dynamic lists | Kit relationship | RFG-161 |
| Header, selection-banner, catalogue, portrait, and pending subrows | Bevy structured row catalogue; Godot library/feedback rows | Kit relationship | RFG-161 |
| Classification badge composition | Bevy Badge; Godot status aliases | Native frame plus small kit composition if needed | RFG-161 |
| Adaptive content/section stacks and summary regions | Bevy content/section/adaptive recipes; Godot repeated container code | Kit relationship only where native Containers are insufficient | RFG-161 |
| Semantic image-replacement field | Bevy Actor portrait picker; Godot portrait evidence | Kit relationship generalized to media replacement; Actor persistence excluded | RFG-161 |
| Context action behavior over a native popup | Bevy host menu behavior; Godot native popups | Native + Theme with documented focus/dismissal configuration | RFG-161 |

## Application-specific exclusions

| Excluded role or source | Why it is not UI Kit content |
| --- | --- |
| Main Menu, World Library, World creation, Join World, Settings, and Manager screens | Finished application screens and workflows; they compose the kit |
| Tabletop Workspace scene, responsive shell recipe, host layers, and controllers | Rookframe application shell and orchestration |
| Package UI Root, contribution slots, Package presentation adapter, and attachment registries | Host SDK/runtime orchestration, not presentation primitives |
| Managed Surface registry, application placement policy, persistence owner, and Package ownership checks | Host policy surrounding the reusable surface relationship |
| Fixed Rails, Builder entry/tool rail, Rooms/Doors catalogue, and legacy rail atlas | Rookframe host navigation and product-specific tools |
| Selected-Rook HUD placement, Rook context query, Actor creation slot, and action routing | Rookframe domain state and host insertion points; only neutral row geometry is reusable |
| Dice tray, dice chooser, modifier chrome, release physics, and credited die artwork | Domain interaction plus rendered/physical tabletop behavior |
| Miniature picker, Package-lock filtering, 3D Miniature preview, and Actor drag/drop | World/Application domain capability and rendered 3D content |
| Actor portrait persistence, Package/World image registries, and file ownership | Actor/World domain workflow; only a neutral image field may be reusable |
| Remote Presence Cursor, scene grid, measurement/target templates, highlights, and placement previews | Rendered world-space presentation outside the 2D design-system boundary |
| `world_content_library.gd`, Package feedback routing, and host confirmation copy | Rookframe domain/application workflow |
| `RookframeUiKit.cs` factory API and `rookframe_components.gd` pass-through factories | Redundant public wrapper/factory layers; semantic roles move to Theme or public scenes |
| Manager/mobile text aliases, safe-area metrics, application scaling, and platform shell helpers | Consuming application/platform policy, consolidated into semantic Theme roles where reusable |
| Legacy R5.3 icon atlas, sample fantasy portrait, Moonwatch mark, and Builder Doorway art | Private shell, example, brand/domain, or narrow host assets; none is required by the public foundation |
| Consumer-named icon or style aliases | Replaced by semantic names; screen-specific duplicates are forbidden |
| SDK Editions, SDK Additive Revisions, Package manifests, runtime UI Kit ranges, and export tooling | Separate Package/SDK lifecycle contracts, not UI Kit runtime content |

## Current Godot source disposition

| Current source | Disposition |
| --- | --- |
| `RookframeTheme.tres` | Palette and reusable variations curated into the new Theme; Manager/legacy aliases are consolidated or excluded |
| `RookframeUiKit.cs` | Semantic values absorbed into Theme/tokens; public C# factories rejected; platform helpers stay application-owned |
| `rookframe_components.gd` | Multi-node reusable relationships became editor-authored scenes in RFG-161; pass-through factories were not copied |
| `managed_surface_state.gd` | Retained-surface behavior informed RFG-161; Package/host policy remains split out |
| `package_presentation_adapter.gd` | Entirely application/runtime orchestration and excluded |
| `world_content_library.gd` | Entirely Rookframe domain/application state and excluded |
| `TabletopWorkspace.tscn`, `tabletop_workspace.gd`, and its JSON contract | Application shell and excluded |
| Generic Godot SVGs | Replaced by the complete semantic manifest and semantic filenames |
| Fonts and Rookframe package frame assets | Included with verified license/provenance and semantic paths |
| R5.3 atlas, sample portrait, domain art, and their imports | Excluded from the public foundation |

## Review conclusion

Every role in the two source implementations has an explicit destination:
foundation/native styling, an RFG-161 reusable relationship, or an intentional
application-specific exclusion. The public foundation includes no application
screen, feature workflow, domain state, host adapter, consumer-named duplicate,
redundant native wrapper, or C# widget hierarchy.
