@tool
extends "res://rookframe/ui/components/forms/task_text_field.gd"

func _style_field() -> void:
	preload("res://rookframe/ui/_internal/forms/silkbound_task_field.gd").apply(self, compact, false)
