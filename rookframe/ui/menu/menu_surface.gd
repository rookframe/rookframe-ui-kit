extends Panel
## Surface recipe: native shape remains intact when optional material grain is absent.
func _ready() -> void:
	theme_changed.connect(_apply_theme, CONNECT_DEFERRED)
	_apply_theme()

func _apply_theme() -> void:
	apply_inset($Grain, get_theme_constant("grain_inset", &"menu_surface"))
	apply_inset($Edge, get_theme_constant("edge_inset", &"menu_surface"))
	$Grain.texture = null
	$Grain.self_modulate = Color.WHITE
	if has_theme_icon("grain", theme_type_variation):
		$Grain.texture = get_theme_icon("grain", theme_type_variation)
		$Grain.self_modulate = get_theme_color("grain_tint", theme_type_variation)
	$Grain.visible = not "--menu-flat-materials" in OS.get_cmdline_user_args()
	$Edge.remove_theme_stylebox_override("panel")
	$Edge.hide()
	if has_theme_stylebox("edge", theme_type_variation):
		$Edge.add_theme_stylebox_override("panel", get_theme_stylebox("edge", theme_type_variation))
		$Edge.show()

func apply_inset(control: Control, inset: float) -> void:
	control.offset_left = inset
	control.offset_top = inset
	control.offset_right = -inset
	control.offset_bottom = -inset
