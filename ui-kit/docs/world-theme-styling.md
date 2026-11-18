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
existing nodes, not new input or content trees. A scene that inherits a core
scene takes the nearest inherited scene's template, unless `presentations` names
the inheriting scene itself. Runtime-created children use core
scenes and inherit the same selection. Native profile Themes inside a template
remain package-owned implementation details.

Core bindings apply appearance before readiness and respond to native Theme
changes. Presentation writes are restored when selection changes; subsequent
caller changes retain priority. Effects settle before their resources change.
Where the selected Theme maps no hook to a behavior script, a core default from
`Appearance.DEFAULT_HOOKS` applies, with or without a Theme; the full-screen
wizard's responsive fit is one.
The hinged leaf bridges its selected Theme across its internal SubViewport.
Core-only installation includes the shared mechanism but no concrete appearance.

Existing package Theme paths, inherited scenes, and their UIDs remain available
for compatibility. New consumers need only the canonical resource and core scenes.

## Semantic tokens

Semantic tokens are named Theme items under the type `RookframeTokens`: colors
as `color` items, spacing, shape, elevation, size and motion as `constant`
items, and each type role as a `font` and a `font_size` item of the same name
plus a `line_spacing_<role>` constant. The UI Kit names them; each theme supplies
their values. `themes/design_tokens.gd` lists every name by item type
(`COLORS`, `CONSTANTS`, `FONTS`, `FONT_SIZES`, or `names(data_type)`) with its
neutral value, and the color pairs that must meet WCAG AA (`AA_PAIRS`): each
`*_content` on its surface, and `content` and `content_muted` on the surfaces,
on `surface_hover`, `surface_pressed` and `accent_subtle`, where text sits on a
row under the pointer, pressed or selected.
The showcase page Design tokens (`--component=design_tokens`) shows every token
of the selected theme. See the [migration steps](../../docs/migration-to-v2.md#semantic-tokens)
for the order of preference in a Package: component, type variation, token read.

Read a token on the Control that draws it and refresh on theme changes:

```gdscript
func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_ring_color = get_theme_color(&"focus_ring", &"RookframeTokens")
		_gap = get_theme_constant(&"space_2", &"RookframeTokens")
```

`line_spacing_<role>` is extra space between lines, as in the native Label
`line_spacing` constant. Motion constants are milliseconds; `motion_ease` holds
a `Tween.TransitionType`.

A theme that omits a token falls back to the neutral default through stock Theme
merging and lookup. `themes/neutral_tokens.tres` is the neutral set. Every
`component_theme.gd` entry merges it before `supplemental_themes` and
`native_theme`, and later sources replace earlier items, so authored tokens win
and omitted ones keep their neutral value. A nearer Theme that does not define a
token hides nothing: Godot continues the lookup through ancestor Themes. Where
no component theme owns a Control, assign the neutral set as the project Theme
(`gui/theme/custom`) or merge it into the project Theme; otherwise Godot returns
its empty defaults for the token type.

A theme package defines every token in its `native_theme` or a supplemental
Theme. `tests/design_tokens.gd` reports tokens a theme entry does not author
and AA pairs below 4.5:1.

## Token-built base layer

`themes/token_base.gd` generates every standard stock control and kit type
variation from a Theme's `RookframeTokens`: colors from the color roles, fonts
and sizes from the type roles, paddings from `space_*`, corners, borders and
focus from the shape tokens, shadows from elevation and `shadow`. It authors no
value of its own, and icons stay Godot's, tinted by color roles. Every
`component_theme.gd` entry builds it from the entry's resolved tokens and lays
it beneath `supplemental_themes` and `native_theme`, so an entry is complete
under any token set, and an entry without sources is the neutral appearance.

A theme owns each type it defines. The base layer supplies only types that no
source defines: it never adds an item to an authored type, because that item
would replace the one the theme inherits from its own base type. A partly
authored type therefore resolves its remaining items through its base type and
then the native classes it extends, as stock Godot does; `OptionButton` with
only an arrow takes the rest from `Button`. Author the whole of a type you
restyle. Without a `default_font` or `default_font_size` in `native_theme`, the
entry uses the `body` role.

Buttons, fields, tabs and rows distinguish normal, hover, pressed, disabled and
focus. A disabled control halves the opacity of its fill and edge and inks its
text and icon in `content_disabled`; unfilled controls differ by that ink alone,
so a theme keeps `content_disabled` apart from `content` and `content_muted`.
`RichTextLabel` emphasis derives from the `body` face: bold moves a variable
face to weight 700, italics use its `ital` or `slnt` axis, and a face without
the axis takes the theme's heavier face of the same family or the synthetic
emphasis of Godot's default Theme. Primary actions use `accent` with `accent_content`, secondary actions the
raised surface, quiet actions no fill until pointed at, destructive actions the
`danger` roles; their hover and pressed fills mix 10% and 16% of `danger` into
`danger_surface`. Godot's unchecked mark is a dark well, so `CheckBox` and
`CheckButton` keep a lit row around it; a theme that wants an outlined box
authors the `CheckBox` icons. Box, flow and grid containers take their gap from
`space_3` and `space_4`, and a Button icon is bounded to `icon_medium`.
Text variations take a type role and an ink role: `RookframeBody` is running
text in `body` and `content`; `RookframeBodyMuted` is secondary running text,
such as a description under a heading, in the same `body` face, size and line
spacing with `content_muted`. `RookframeMeta` is the smaller `meta` role for
captions and counts. `RookframeTextStack` is a `VBoxContainer` for lines that
read as one block, such as a heading over its meta line: its `separation` is
`space_1`, where other box containers take `space_3`. A theme may author any of
them; one it leaves out comes from its tokens.

`tests/token_base.gd` lists the stock controls, checks that every
variation a kit scene or script assigns is declared, along with the
variations offered to Packages such as `RookframeBodyMuted` and
`RookframeTextStack`, that every value
follows the tokens, that the text it builds from each theme's tokens meets WCAG
AA (label inks on `surface`, Button inks on each state fill, including
`danger_content` on the destructive hover and pressed fills), and that authored
types are left alone. The mapping compiler's
usages below (`menu_*`, `editor_*`, `settings_*`, `components_switch*`) are not
part of the layer; without a mapping they resolve through their stock class.

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
