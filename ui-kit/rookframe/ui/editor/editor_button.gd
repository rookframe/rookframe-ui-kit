@tool
extends Button
## Density and semantic appearance only; Button owns all input and toggle state.
@export_enum("editor.button.tool", "editor.button.action", "editor.button.standard") var usage := "editor.button.tool":
	set(value):
		usage = value
		_refresh()
@export var compact := false:
	set(value):
		compact = value
		_refresh()
var _refresh_pending := false


func _ready() -> void:
	_refresh()


func set_compact(enabled: bool) -> void:
	compact = enabled


func _refresh() -> void:
	_refresh_pending = false
	theme_type_variation = usage.replace(".", "_") + ("__compact" if compact else "")
	var height := get_theme_constant("minimum_height")
	custom_minimum_size.y = height
	if usage == "editor.button.tool":
		custom_minimum_size.x = height


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED and is_node_ready() and not _refresh_pending:
		_refresh_pending = true
		_refresh.call_deferred()
