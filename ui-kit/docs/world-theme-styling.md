# Theme activation and composition

Every optional theme exposes one native Godot Theme at
`res://rookframe/ui/themes/<theme-name>/theme.tres`. The package provides its theme
name. Install packages independently of selecting them. Assign the resource in
the owning Control's Inspector or code:

```gdscript
ui_root.theme = load("res://rookframe/ui/themes/<theme-name>/theme.tres")
var panel = preload("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn").instantiate()
ui_root.add_child(panel)
```

Use the same public component scenes for every theme. The selected Theme supplies
native items and optional presentation: surfaces, bindings, materials, shaders,
and responsive styling. Hosts own selection and persistence. Assign another
Theme (or null for native defaults) without replacing component nodes, content,
signals, focus, or application state. A local Theme remains an explicit scope.

`themes/component_theme.gd` extends native `Theme`. `native_theme` accepts an
existing authored or compiled Theme; `supplemental_themes` contributes additional
native roles, with the primary Theme taking precedence. `presentations` maps core scene resource
paths to inherited appearance templates; `presentation_hooks` maps core behavior
script paths to presentation-only strategy scripts. The component calls its
existing visual hooks on the selected strategy. Strategies receive the retained
component and never replace its behavior script. Templates supply properties on
existing nodes, not new input or content trees. Runtime-created children use core
scenes and inherit the same selection. Native profile Themes inside a template
remain package-owned implementation details.

Core bindings apply appearance before readiness and respond to native Theme
changes. Presentation writes are restored when selection changes; subsequent
caller changes retain priority. Effects settle before their resources change.
The hinged leaf bridges its selected Theme across its internal SubViewport.
Core-only installation includes the shared mechanism but no concrete appearance.

Existing package Theme paths, inherited scenes, and their UIDs remain available
for compatibility. New consumers need only the canonical resource and core scenes.

## Native mapping compiler
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
