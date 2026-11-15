@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/theme/silkbound_tokens.gd")




func _style_number(control, number: Label) -> void:
	Appearance.override_item(number, "font_sizes", "font_size", 20)
	preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(number, 1.1)

func _style_cell(control, cell: VBoxContainer) -> void:
	Appearance.override_item(cell, "constants", &"separation", 8)

func _style_rail(control, rail: HBoxContainer) -> void:
	Appearance.override_item(rail, "constants", &"separation", 6)

func _step_icon_color(control) -> Color:
	return Tokens.color(&"content")

func _step_number_color(control, state_name: String) -> Color:
	return Tokens.color(&"accent_content") if state_name == "current" else Tokens.color(&"content_muted")

func _connector_color(control, complete: bool) -> Color:
	return Tokens.color(&"accent") if complete else Tokens.color(&"divider")
