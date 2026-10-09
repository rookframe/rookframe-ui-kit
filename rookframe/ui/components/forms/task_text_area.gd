@tool
extends "res://rookframe/ui/components/forms/text_area.gd"
## Phone density for the existing task multiline field relationship.
@export var silkbound := false
@export var compact := false:
	set(next):
		compact = next
		_refresh()

func _refresh() -> void:
	super._refresh()
	if not is_inside_tree():
		return
	preload("res://rookframe/ui/_internal/forms/silkbound_task_field.gd").apply(self, compact, true)
