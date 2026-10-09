@tool
extends "res://rookframe/ui/components/forms/text_field.gd"
## Phone density for the existing task field relationship.
@export var silkbound := false
@export var compact := false:
	set(next):
		compact = next
		_refresh()

func _refresh() -> void:
	super._refresh()
	if not is_inside_tree():
		return
	preload("res://rookframe/ui/_internal/forms/silkbound_task_field.gd").apply(self, compact, false)
