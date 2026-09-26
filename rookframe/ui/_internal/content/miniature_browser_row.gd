@tool
extends Button

func _ready() -> void:
	get_node(^"Copy").minimum_size_changed.connect(_fit)
	_fit()

func _fit() -> void:
	custom_minimum_size.y = maxf(60, get_node(^"Copy").get_combined_minimum_size().y + 12)
