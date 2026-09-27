@tool
extends Button

func _ready() -> void:
	get_node(^"Content").minimum_size_changed.connect(_fit)
	get_node(^"Content/Stage/Preview").child_entered_tree.connect(_preview_added)
	_fit()

func _fit() -> void:
	custom_minimum_size.y = maxf(184, get_node(^"Content").get_combined_minimum_size().y + 16)

func _preview_added(_child: Node) -> void:
	get_node(^"Content/Stage/Fallback").hide()
