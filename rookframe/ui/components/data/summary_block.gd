@tool
extends VBoxContainer
## Authored review block with data-driven label/value rows and optional copy.
const ROW = preload("res://rookframe/ui/_internal/data/summary_pair.tscn")
const STAT = preload("res://rookframe/ui/_internal/data/summary_stat.tscn")

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
