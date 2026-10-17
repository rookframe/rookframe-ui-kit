@tool
extends "res://rookframe/ui/components/forms/text_area.gd"
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Phone density for the existing task multiline field relationship.
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
	if Appearance.has_hook(self, &"_style_field"):
		Appearance.invoke(self, &"_style_field", [])
		return
	get_node(^"Editor").custom_minimum_size.y = 112 if get_node(^"Editor") is TextEdit else 44


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)

func _presentation_changed() -> void:
	_refresh()
