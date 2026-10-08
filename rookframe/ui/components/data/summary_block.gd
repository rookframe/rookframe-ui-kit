@tool
extends VBoxContainer
## Authored review block with data-driven label/value rows and optional copy.
@export var silkbound := false
const ROW = preload("res://rookframe/ui/_internal/data/summary_pair.tscn")
const STAT = preload("res://rookframe/ui/_internal/data/summary_stat.tscn")

func _ready() -> void:
	get_viewport().size_changed.connect(_fit)
	_fit()

func set_stats(stats: Array[Dictionary]) -> void:
	var container := get_node(^"Content/Stats")
	container.visible = not stats.is_empty()
	while container.get_child_count() < stats.size():
		container.add_child(STAT.instantiate())
	for index in container.get_child_count():
		var row := container.get_child(index)
		row.visible = index < stats.size()
		if row.visible:
			row.get_node(^"Label").text = str(stats[index].get("label", ""))
			row.get_node(^"Value").text = str(stats[index].get("value", ""))
	_fit()

func configure(title: String, icon: Texture2D, pairs: Array[Dictionary], copy: String = "") -> void:
	get_node(^"Content/Heading/Title").text = title
	get_node(^"Content/Heading/Icon").texture = icon
	var rows := get_node(^"Content/Rows")
	while rows.get_child_count() > pairs.size():
		var child := rows.get_child(rows.get_child_count() - 1)
		rows.remove_child(child)
		child.queue_free()
	while rows.get_child_count() < pairs.size():
		rows.add_child(ROW.instantiate())
	for index in pairs.size():
		var row := rows.get_child(index)
		row.get_node(^"Inset/Row/Label").text = str(pairs[index].get("label", ""))
		row.get_node(^"Inset/Row/Value").text = str(pairs[index].get("value", ""))
	get_node(^"Content/Copy").text = copy
	get_node(^"Content/Copy").visible = not copy.is_empty()
	_fit()

func _fit() -> void:
	var phone := get_viewport_rect().size.y <= 560
	var tablet := get_viewport_rect().size.x <= 1150 and not phone
	add_theme_constant_override("separation", 8 if phone else 12 if tablet else 20)
	get_node(^"Content").add_theme_constant_override("separation", 4 if phone else 8 if tablet else 12)
	get_node(^"Content/Heading/Title").add_theme_font_size_override("font_size", 15 if phone else 17 if tablet else 22)
	get_node(^"Content/Heading/Icon").custom_minimum_size = Vector2(18, 18) if phone else Vector2(23, 23)
	get_node(^"Content/Copy").add_theme_font_size_override("font_size", 11 if phone else 12 if tablet else 16)
	for row in get_node(^"Content/Stats").get_children():
		row.get_node(^"Label").add_theme_font_size_override("font_size", 12 if tablet else 16)
		row.get_node(^"Value").add_theme_font_size_override("font_size", 18 if tablet else 20)
	for row in get_node(^"Content/Rows").get_children():
		for edge in ["top", "bottom"]:
			row.get_node(^"Inset").add_theme_constant_override("margin_" + edge, 5 if phone else 9 if tablet else 14)
		for label in [^"Inset/Row/Label", ^"Inset/Row/Value"]:
			row.get_node(label).add_theme_font_size_override("font_size", 11 if phone else 12 if tablet else 16)

	if silkbound:
		_fit_silkbound()


func _fit_silkbound() -> void:
	var phone := get_viewport_rect().size.y <= 560 or get_viewport_rect().size.x <= 740
	var tablet := get_viewport_rect().size.x <= 1300 and not phone
	get_node(^"Rule").color = Color("3e4346")
	add_theme_constant_override("separation", 6 if phone or tablet else 16)
	get_node(^"Content").add_theme_constant_override("separation", 4 if phone else 6 if tablet else 12)
	get_node(^"Content/Heading").add_theme_constant_override("separation", 10 if phone else 12)
	get_node(^"Content/Heading/Title").add_theme_font_override("font",preload("res://rookframe/ui/theme/silkbound_medium.tres"))
	get_node(^"Content/Heading/Title").add_theme_font_size_override("font_size",21 if phone else 22 if tablet else 24)
	get_node(^"Content/Heading/Title").add_theme_color_override("font_color",Color("e7e7dd"))
	get_node(^"Content/Heading/Icon").self_modulate = Color("d0be8e")
	get_node(^"Content/Heading/Icon").custom_minimum_size = Vector2(22,22) if phone else Vector2(26,26)
	get_node(^"Content/Copy").add_theme_font_size_override("font_size",17 if phone or tablet else 20)
	get_node(^"Content/Copy").add_theme_color_override("font_color",Color("aebabe"))
	for row in get_node(^"Content/Stats").get_children():
		row.get_node(^"Label").add_theme_font_size_override("font_size",17 if tablet else 20)
		row.get_node(^"Label").add_theme_color_override("font_color",Color("aebabe"))
		row.get_node(^"Value").add_theme_font_override("font",preload("res://rookframe/ui/theme/silkbound_medium.tres"))
		row.get_node(^"Value").add_theme_font_size_override("font_size",22 if tablet else 27)
		row.get_node(^"Value").add_theme_color_override("font_color",Color("e7e7dd"))
	for row in get_node(^"Content/Rows").get_children():
		row.get_node(^"Rule").color = Color("3e4346")
		row.get_node(^"Inset/Row/Label").custom_minimum_size.x = 0
		for edge in ["top","bottom"]:
			row.get_node(^"Inset").add_theme_constant_override("margin_"+edge,6 if phone else 2 if tablet else 8)
		for label in [^"Inset/Row/Label",^"Inset/Row/Value"]:
			row.get_node(label).add_theme_font_size_override("font_size",18 if phone or tablet else 21)
			row.get_node(label).add_theme_color_override("font_color",Color("aebabe") if label == ^"Inset/Row/Label" else Color("e7e7dd"))

	for label in [get_node(^"Content/Heading/Title"), get_node(^"Content/Copy")]:
		preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(label,1.2 if phone else 1.35 if label == get_node(^"Content/Copy") else 1.4)
	for row in get_node(^"Content/Rows").get_children():
		for path in [^"Inset/Row/Label",^"Inset/Row/Value"]:
			preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(path),1.15 if phone else 1.2 if tablet else 1.3)
	for row in get_node(^"Content/Stats").get_children():
		for path in [^"Label",^"Value"]:
			preload("res://rookframe/ui/theme/silkbound_line_height.gd").apply(row.get_node(path),1.2)
