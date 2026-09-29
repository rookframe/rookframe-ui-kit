@tool
extends Button

func _ready() -> void:
	get_node(^"Content").minimum_size_changed.connect(_fit)
	get_node(^"Content/Stage/Preview").child_entered_tree.connect(func(_child): get_node(^"Content/Stage/Fallback").hide())
	_fit()

func arrange(width: float, phone: bool, tablet: bool) -> void:
	var inset := 8 if phone else 12
	var content := get_node(^"Content") as VBoxContainer
	content.offset_left = inset
	content.offset_top = inset
	content.offset_right = -inset
	content.offset_bottom = -inset
	content.add_theme_constant_override("separation", 6 if phone else 16)
	get_node(^"Content/Stage").custom_minimum_size.y = 84 if phone else (96 if tablet else 192)
	var copy := get_node(^"Content/Copy") as VBoxContainer
	copy.add_theme_constant_override("separation", 2 if phone else 4)
	for label in copy.get_children():
		label.custom_minimum_size.x = maxf(0, width - inset * 2)
	get_node(^"Content/Copy/Title").add_theme_font_size_override("font_size", 16 if phone else (20 if tablet else 22))
	get_node(^"Content/Copy/Package").add_theme_font_size_override("font_size", 11 if phone else 13)
	_fit()

func _fit() -> void:
	var content := get_node(^"Content") as VBoxContainer
	custom_minimum_size.y = content.get_combined_minimum_size().y + content.offset_top - content.offset_bottom
