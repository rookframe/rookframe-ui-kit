@tool
extends PanelContainer
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
	pass


func get_surface_style() -> StyleBox:
	return get_theme_stylebox("panel")
