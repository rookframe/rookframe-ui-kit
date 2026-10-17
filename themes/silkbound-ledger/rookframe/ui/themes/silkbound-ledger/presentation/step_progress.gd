@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _style_number(control, number: Label) -> void:
	Appearance.override_item(number, "font_sizes", "font_size", 20)
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(number, 1.1)

func _style_cell(control, cell: VBoxContainer) -> void:
	Appearance.override_item(cell, "constants", &"separation", 8)

func _style_rail(control, rail: HBoxContainer) -> void:
	Appearance.override_item(rail, "constants", &"separation", 6)

func _step_icon_color(control) -> Color:
	return Color("e7e7dd")

func _step_number_color(control, state_name: String) -> Color:
	return Color("151719") if state_name == "current" else Color("aebabe")

func _connector_color(control, complete: bool) -> Color:
	return Color("ceccb3") if complete else Color("3e4346")
