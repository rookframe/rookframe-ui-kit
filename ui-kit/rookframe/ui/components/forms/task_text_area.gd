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
	_style_field()

func _style_field() -> void:
	get_node(^"Editor").custom_minimum_size.y = 112 if get_node(^"Editor") is TextEdit else 44
