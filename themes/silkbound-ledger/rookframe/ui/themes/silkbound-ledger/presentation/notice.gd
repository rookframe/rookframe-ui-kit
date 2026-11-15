@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
const Tokens = preload("res://rookframe/ui/theme/silkbound_tokens.gd")

## Information, pending, success and error tones.
const TONES: Array[StringName] = [&"info", &"info", &"success", &"danger"]




func _tone_color(control) -> Color:
	return Tokens.color(TONES[control.tone])
