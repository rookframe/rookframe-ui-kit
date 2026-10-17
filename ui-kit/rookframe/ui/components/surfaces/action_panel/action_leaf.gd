@tool
extends PanelContainer
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Nine-patch material in its original texel density; children use normal logical units.
@export_enum("Body", "Header", "Footer", "Emblem") var surface := 0:
	set(value):
		surface = value
		_refresh()
@export var tiled_body := false:
	set(value):
		tiled_body = value
		_refresh()
var _tiled_style: StyleBoxTexture
func _ready() -> void:
	resized.connect(_refresh)
	_refresh()
func _refresh() -> void:
	if Appearance.has_hook(self, &"_refresh"):
		Appearance.invoke(self, &"_refresh", [])
		return
	pass


func get_surface_style() -> StyleBox:
	if Appearance.has_hook(self, &"get_surface_style"):
		return Appearance.invoke(self, &"get_surface_style", [])
	return get_theme_stylebox("panel")


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
