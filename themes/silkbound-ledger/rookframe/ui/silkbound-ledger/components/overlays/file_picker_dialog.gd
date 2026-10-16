@tool
extends "res://rookframe/ui/components/overlays/file_picker_dialog.gd"

func _style_spacing(compact: bool) -> void:
	$Shell/Content.add_theme_constant_override(&"separation", 8 if compact else 16)
