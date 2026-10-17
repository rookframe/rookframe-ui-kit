extends Button
## The source supplies content; Godot owns the native tooltip lifecycle.
const Tooltip = preload("res://rookframe/ui/components/feedback/tooltip.tscn")

func _make_custom_tooltip(for_text: String) -> Object:
	var content := Tooltip.instantiate()
	content.text = for_text
	return content
