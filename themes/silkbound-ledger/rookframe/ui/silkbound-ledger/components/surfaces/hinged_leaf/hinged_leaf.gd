extends "res://rookframe/ui/components/surfaces/hinged_leaf/hinged_leaf.gd"

func _binding_tint(extension: float) -> Color:
	return Color.WHITE.lerp(Color(0.80, 0.83, 0.84), 1.0 - extension)
