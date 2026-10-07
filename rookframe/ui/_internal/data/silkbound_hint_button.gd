extends Button
## Stock Godot tooltip content for a collection's inspection button.
var hint_title := ""
var hint_summary := ""

func _make_custom_tooltip(_for_text: String) -> Object:
	if hint_summary.is_empty():
		return null
	var content := preload("res://rookframe/ui/components/feedback/silkbound_tooltip.tscn").instantiate()
	content.get_node(^"Title").text = hint_title
	content.get_node(^"Summary").text = hint_summary
	return content
