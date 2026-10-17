# Native Theme composition

`menu/menu_theme.gd` compiles caller-supplied mapping and material scripts into
a native Theme. Optional additional mapping scripts extend its shared usages.
The compiler does not preload a concrete theme, palette or material package.

`apply_usages(control, usages, compact)` and
`usage_variant(theme, usages, base_type, compact)` project ordered native Theme
variations. Later usages override only authored items, including explicit zero;
removing an item reveals its predecessor. Compact projection occurs within each
usage. Native local overrides keep their priority. Reapply the projection when
usages or the owning Theme change.

`apply_world_tooltips(target, authored)` derives tooltip defaults from composed
editor items while preserving explicit tooltip items in the authored Theme.
Call it after composition and after native Theme changes.

`components.button` and `components.button.primary` are compiled aliases for
standard and primary menu styles. The primary alias contains only differences,
so broad button overrides remain effective. `components.button.destructive`
supplies the destructive role. The shared `components/actions/button.tscn`
selects the corresponding native `components_button`,
`components_button_primary` or `components_button_destructive` type through
`variant`, and appends `__compact` through `compact`. Theme mappings must define
compact inheritance as well as normal inheritance. The same types style native
text, icon-with-text and icon-only content. Compatibility menu/editor recipes
retain their existing `usage` property.

Hosts own routes, labels, World state and responsive composition. Concrete
geometry, materials and mapping sets belong to optional packages.
