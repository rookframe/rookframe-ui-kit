@tool
extends Node2D
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Decoration only: never intercept pointer input or contribute to minimum size.
func _draw() -> void:
	if Appearance.has_hook(self, &"_draw"):
		Appearance.invoke(self, &"_draw", [])
		return
	pass
