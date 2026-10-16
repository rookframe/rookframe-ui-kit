@tool
extends "res://rookframe/ui/components/feedback/step_progress.gd"

func _style_number(number: Label) -> void:
	number.add_theme_font_size_override("font_size", 20)
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(number, 1.1)

func _style_cell(cell: VBoxContainer) -> void:
	cell.add_theme_constant_override(&"separation", 8)

func _style_rail(rail: HBoxContainer) -> void:
	rail.add_theme_constant_override(&"separation", 6)

func _step_icon_color() -> Color:
	return Color("e7e7dd")

func _step_number_color(state_name: String) -> Color:
	return Color("151719") if state_name == "current" else Color("aebabe")

func _connector_color(complete: bool) -> Color:
	return Color("ceccb3") if complete else Color("3e4346")
