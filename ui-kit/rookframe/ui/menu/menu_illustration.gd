extends TextureRect
## Decorative recipe. Assets and tint are resolved through the active Theme.
func _ready() -> void:
	theme_changed.connect(_apply_theme, CONNECT_DEFERRED)
	_apply_theme()

func _apply_theme() -> void:
	texture = null
	self_modulate = Color.WHITE
	if has_theme_icon("image", theme_type_variation):
		texture = get_theme_icon("image", theme_type_variation)
	if has_theme_color("tint", theme_type_variation):
		self_modulate = get_theme_color("tint", theme_type_variation)
