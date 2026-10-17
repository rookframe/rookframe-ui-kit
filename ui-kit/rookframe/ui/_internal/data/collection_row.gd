extends HBoxContainer
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")

func _draw() -> void:
	if Appearance.has_hook(self, &"_draw"):
		Appearance.invoke(self, &"_draw", [])
		return
	pass


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
