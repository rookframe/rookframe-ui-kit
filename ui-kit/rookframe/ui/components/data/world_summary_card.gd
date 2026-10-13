@tool
extends VBoxContainer

## Compact retained-record summary used when the same identity, Package, and
## availability relationship recurs in more than one application route.
## Callers own the record data and connect the native action Buttons.

@export var facts_visible := true:
	set(value):
		facts_visible = value
		_refresh()

@export var actions_visible := false:
	set(value):
		actions_visible = value
		_refresh()

@export var kicker_text := "SELECTED WORLD":
	set(value):
		kicker_text = value
		_refresh()

@export var privacy_text := "PRIVATE":
	set(value):
		privacy_text = value
		_refresh()

@export var package_name := "Package":
	set(value):
		package_name = value
		_refresh()

@export_multiline var detail_text := "":
	set(value):
		detail_text = value
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var kicker := get_node_or_null(^"Margin/Content/Kicker/Text") as Label
	var privacy := get_node_or_null(^"Margin/Content/Kicker/Privacy") as Label
	var package_title := get_node_or_null(^"Margin/Content/Package/Copy/Name") as Label
	var package_detail := get_node_or_null(^"Margin/Content/Package/Copy/Detail") as Label
	var facts := get_node_or_null(^"Margin/Content/Facts") as Control
	var actions := get_node_or_null(^"Margin/Content/Actions") as Control
	if kicker != null:
		kicker.text = kicker_text
	if privacy != null:
		privacy.text = privacy_text
	if package_title != null:
		package_title.text = package_name
	if package_detail != null:
		package_detail.text = detail_text
		package_detail.visible = not detail_text.is_empty()
	if facts != null:
		facts.visible = facts_visible
	if actions != null:
		actions.visible = actions_visible
