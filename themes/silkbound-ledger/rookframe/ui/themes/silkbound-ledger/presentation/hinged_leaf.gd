@tool
extends RefCounted
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")




func _binding_tint(control, extension: float) -> Color:
	return Color.WHITE.lerp(Color(0.80, 0.83, 0.84), 1.0 - extension)
