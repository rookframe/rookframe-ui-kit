@tool
extends RefCounted
## Theme-independent fit of the full-screen wizard, used where the owning Theme
## supplies no presentation of its own. Sizes and colors are RookframeTokens.
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")

func _fit(control) -> void:
	if not control.is_node_ready():
		return
	var phone: bool = control.is_compact()
	var tablet: bool = control.is_tablet()
	var target := _size(control, &"target_minimum")
	var action := _size(control, &"action_height")
	var outer := _size(control, &"space_3" if phone else &"space_4" if tablet else &"space_5")
	Appearance.write(control.get_node(^"Ledger"), ^"visible", false)
	Appearance.write(control.get_node(^"StageSurface"), ^"visible", false)
	var layout: Control = control.get_node(^"Layout")
	Appearance.write(layout, ^"offset_left", outer)
	Appearance.write(layout, ^"offset_top", outer)
	Appearance.write(layout, ^"offset_right", -outer)
	Appearance.write(layout, ^"offset_bottom", -outer)
	Appearance.override_item(layout, "constants", "separation", _size(control, &"space_2" if phone else &"space_4"))
	# A short viewport keeps the chrome to one target row each and folds the step names into the header.
	Appearance.write(control.get_node(^"Layout/Header"), ^"custom_minimum_size:y", target if phone else action + _size(control, &"space_2"))
	Appearance.write(control.get_node(^"Layout/Steps"), ^"custom_minimum_size:y", _size(control, &"space_1") if phone else action)
	Appearance.write(control.get_node(^"Layout/Footer"), ^"custom_minimum_size:y", target if phone else action + _size(control, &"space_2"))
	Appearance.override_item(control.get_node(^"Layout/Body"), "constants", "separation", _size(control, &"space_4" if phone else &"space_5"))
	Appearance.write(control.get_context_slot(), ^"custom_minimum_size:x", control.size.x * (0.25 if phone else 0.3))
	Appearance.write(control.get_node(^"Layout/Header/Title"), ^"visible", not phone)
	Appearance.write(control.get_node(^"Layout/Header/Row/CurrentStep"), ^"visible", phone)
	Appearance.write(control.get_node(^"Layout/Header/Row/Brand/Subtitle"), ^"visible", not phone)
	var mark := _size(control, &"icon_medium" if phone else &"icon_large")
	Appearance.write(control.get_node(^"Layout/Header/Row/Icon"), ^"custom_minimum_size", Vector2(mark, mark))
	for step in control._steps:
		Appearance.write(step.get_node(^"Row"), ^"visible", not phone)
		Appearance.write(step.get_node(^"Row/Marker"), ^"custom_minimum_size", Vector2(mark, mark))
	control._fit_primary()
	control.set_step(control._index)
	control._fit_surfaces.call_deferred()

func _fit_primary(control) -> void:
	var target := _size(control, &"target_minimum")
	for path: NodePath in [^"Layout/Header/Row/Close", ^"Layout/Footer/Row/Back", ^"Layout/Footer/Row/Restart", ^"Layout/Footer/Row/Primary"]:
		var action: Button = control.get_node(path)
		# Icon-only actions are square targets; labelled ones keep their own width.
		Appearance.write(action, ^"custom_minimum_size", Vector2(target if action.text.is_empty() else 0, target))
		Appearance.override_item(action, "constants", "icon_max_width", _size(control, &"icon_medium"))

func _style_step(control, step: Control, number: int, index: int) -> void:
	var marker: PanelContainer = step.get_node(^"Row/Marker")
	Appearance.write(marker, ^"theme_type_variation", &"RookframeStepCurrent" if number == index else &"RookframeStepComplete" if number < index else &"RookframeStepPending")
	Appearance.override_item(step.get_node(^"Row/Name"), "colors", "font_color", _color(control, &"content" if number <= index else &"content_muted"))
	Appearance.override_item(step.get_node(^"Row/Marker/Number"), "colors", "font_color", _color(control, &"accent_content" if number == index else &"content_muted"))
	Appearance.write(step.get_node(^"Row/Marker/Done"), ^"self_modulate", _color(control, &"content"))
	Appearance.write(step.get_node(^"Rule"), ^"color", _color(control, &"accent" if number == index else &"border_strong" if number < index else &"divider"))

## A token of the owning Theme, or its neutral value where no Theme supplies tokens.
func _size(control: Control, token: StringName) -> int:
	return control.get_theme_constant(token, Tokens.TYPE) if control.has_theme_constant(token, Tokens.TYPE) else Tokens.CONSTANTS[token]

func _color(control: Control, token: StringName) -> Color:
	return control.get_theme_color(token, Tokens.TYPE) if control.has_theme_color(token, Tokens.TYPE) else Tokens.COLORS[token]
