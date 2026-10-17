@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_field(control) -> void:
	preload("res://rookframe/ui/_internal/forms/silkbound_task_field.gd").apply(control, control.compact, true)
