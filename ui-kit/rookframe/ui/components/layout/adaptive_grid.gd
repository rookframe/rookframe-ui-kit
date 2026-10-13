@tool
extends GridContainer

## Container-width adaptive grid for equal-priority cells.
##
## Godot's GridContainer owns the grid itself. This script supplies only the
## missing relationship: choosing a supported column count from this
## container's measured width.

signal column_count_changed(column_count: int)

@export_range(1, 8, 1) var minimum_columns := 1:
	set(value):
		minimum_columns = maxi(1, value)
		_update_columns()

@export_range(1, 8, 1) var maximum_columns := 4:
	set(value):
		maximum_columns = maxi(1, value)
		_update_columns()

@export_range(80.0, 640.0, 4.0, "suffix:px") var minimum_column_width := 220.0:
	set(value):
		minimum_column_width = maxf(80.0, value)
		_update_columns()


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED or what == NOTIFICATION_THEME_CHANGED:
		_update_columns()


func _update_columns() -> void:
	if not is_inside_tree() or size.x <= 0.0:
		return
	var lower := mini(minimum_columns, maximum_columns)
	var upper := maxi(minimum_columns, maximum_columns)
	var gap := float(get_theme_constant(&"h_separation"))
	var measured := floori((size.x + gap) / (minimum_column_width + gap))
	var next_columns := clampi(measured, lower, upper)
	if columns == next_columns:
		return
	columns = next_columns
	column_count_changed.emit(columns)
