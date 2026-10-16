extends Control
## Two stationary, riveted leather tabs. The bounds span the joined edges.
func _ready() -> void:
	resized.connect(queue_redraw)
func _draw() -> void:
	pass
