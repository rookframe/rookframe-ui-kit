@tool
extends PanelContainer
## Nine-patch material in its original texel density; children use normal logical units.
@export_enum("Body", "Header", "Footer", "Emblem") var surface := 0:
	set(value):
		surface = value
		_refresh()
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
	skin.add_theme_stylebox_override("panel", STYLES[surface])
	skin.size = size / .4
