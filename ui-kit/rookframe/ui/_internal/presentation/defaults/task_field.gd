@tool
extends RefCounted
## Theme-independent density of the task fields, used where the owning Theme
## supplies no presentation of its own. Gaps and heights are RookframeTokens.
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/themes/design_tokens.gd")

func _style_field(control) -> void:
	var editor: Control = control.get_node(^"Editor")
	var compact: bool = control.compact
	# Label, help, editor and error read as one field; compact closes them up.
	Appearance.override_item(control, "constants", "separation", _size(control, &"space_1" if compact else &"space_2"))
	var height := _size(control, &"target_minimum")
	if editor is TextEdit:
		# Compact keeps one comfortable line above the touch target; otherwise about three.
		height = _size(control, &"action_height") + _size(control, &"space_3") if compact else 2 * _size(control, &"action_height") + _size(control, &"space_2")
		if control.has_theme_constant_override("editor_minimum_height"):
			height = control.get_theme_constant("editor_minimum_height")
	Appearance.write(editor, ^"custom_minimum_size:y", height)
	_font_size(control, control.get_node(^"Label"), "label_font_size")
	_font_size(control, editor, "editor_font_size")

## A caller's documented font-size constant override, applied to the part it names.
func _font_size(control: Control, part: Control, constant: String) -> void:
	if control.has_theme_constant_override(constant):
		Appearance.override_item(part, "font_sizes", "font_size", control.get_theme_constant(constant))
		part.set_meta(&"_task_field_size", true)
	elif part.has_meta(&"_task_field_size"):
		Appearance.override_item(part, "font_sizes", "font_size", null)
		part.remove_meta(&"_task_field_size")

## A token of the owning Theme, or its neutral value where no Theme supplies tokens.
func _size(control: Control, token: StringName) -> int:
	return control.get_theme_constant(token, Tokens.TYPE) if control.has_theme_constant(token, Tokens.TYPE) else Tokens.CONSTANTS[token]
