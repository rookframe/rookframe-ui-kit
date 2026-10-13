# Shared Fantasy and Cyberpunk styling

The optional `themes/fantasy` and `themes/cyberpunk` packages supply the public
`res://rookframe/ui/menu/MenuTheme.tres` and
`res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres` own their complete native
styling, including the Worlds list and hub and escape menu. Consumers
assign these Theme resources directly; they do not subclass the compiler or copy
palettes, Materials or Theme mappings into an application.

`menu/world_list_theme_map.gd` and `menu/world_toolbar_theme_map.gd` map semantic
usages to Materials. Each theme's `materials/world_list_materials.gd` supplies its
palette, selected row states and backdrop, deriving transparent content padding
from that theme's Settings surface. Shared dimensions live in
`menu/materials/world_list_geometry.gd`; `menu/materials/menu_geometry.gd` supplies
the keeper-menu composition dimensions. Application scenes, routes, labels,
World state and responsive composition remain application-owned.

`menu/menu_theme.gd` provides `apply_usages(control, usages, compact)` and
`usage_variant(theme, usages, base_type, compact)` for ordered native Theme
variations. Later usages override only authored items, including explicit zero;
removing an item reveals its predecessor. Compact projection occurs within each
usage, and Godot retains native local override priority. Call the projection
again after changing usages or receiving a Theme change.

`menu/menu_theme.gd` also owns `apply_world_tooltips(target, authored)`. Call it
after composing a World Theme and again on native Theme changes. It derives
tooltip defaults from the composed editor items, preserving any explicit
tooltip items in the authored Theme without filling the sparse source.

The ordered `components.button` and `components.button.primary` usages are
compiled aliases of the existing standard and primary menu styles. The primary
alias contains only differences, so broad button overrides remain effective.
The public button scene paths and their single `usage` property remain unchanged.

`showcase/tests/world_theme.gd` checks both native Themes, selected/compact row styling,
tooltip resources, and sparse ordered overrides. Application integration suites
cover routing, live selection and Package Theme fallback. These checks establish
resource behavior; native specimen review remains the visual acceptance step.
