extends Control
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Two stationary, riveted leather tabs. The bounds span the joined edges.
func _ready() -> void:
	resized.connect(queue_redraw)
func _draw() -> void:
	if Appearance.has_hook(self, &"_draw"):
		Appearance.invoke(self, &"_draw", [])
		return
	pass


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
