# Changelog

This repository follows independent UI Kit SemVer. Stable v1.0.0 has not been
published.

## v1.0.0-rc.1 candidate

### Added

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
- Distinct pinned upstream drawings for every semantic icon role.
- Complete public identity, component, semantic icon, native composition,
  accessibility/input, compatibility, licensing, attribution, and migration
  documentation.
- A reviewed clean-project gd-plug consumer that configures, styles, and
  connects public resources through ordinary Godot authoring.

### Fixed

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
