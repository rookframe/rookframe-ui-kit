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
const STYLES = [
	preload("res://rookframe/ui/assets/action-panel/body.tres"),
	preload("res://rookframe/ui/assets/action-panel/header.tres"),
	preload("res://rookframe/ui/assets/action-panel/footer.tres"),
	preload("res://rookframe/ui/assets/action-panel/emblem.tres")
]
func _ready() -> void:
	resized.connect(_refresh)
	_refresh()
func _refresh() -> void:
	if not is_node_ready():
		return
	var skin: Panel = get_node("Skin/Surface")
	var style: StyleBoxTexture = STYLES[surface]
	if tiled_body and surface == 0:
		if _tiled_style == null:
			_tiled_style = style.duplicate()
			_tiled_style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
			_tiled_style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		style = _tiled_style
	skin.add_theme_stylebox_override("panel", style)
	skin.size = size / .4
