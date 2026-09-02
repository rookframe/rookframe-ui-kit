@tool
extends Button

## Compact navigation or management action with one native button target.
## The caller owns action policy and connects the inherited pressed signal.

enum Tone {
	STANDARD,
	DANGER,
}

@export var title := "Action":
	set(value):
		title = value
		_refresh()

@export_multiline var description := "Supporting action detail":
	set(value):
		description = value
		_refresh()

@export var action_label := "›":
	set(value):
		action_label = value
		_refresh()

@export var tone := Tone.STANDARD:
	set(value):
		tone = Tone.DANGER if value == Tone.DANGER else Tone.STANDARD
		_refresh()


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	var title_label := get_node_or_null(^"Content/Copy/Title") as Label
	var description_label := get_node_or_null(^"Content/Copy/Description") as Label
	var action := get_node_or_null(^"Content/Action") as Label
	theme_type_variation = (
		&"RookframeDangerButton" if tone == Tone.DANGER else &"RookframeSecondaryButton"
	)
	if title_label != null:
		title_label.text = title
		title_label.theme_type_variation = (
			&"RookframeError" if tone == Tone.DANGER else &"RookframeIdentity"
		)
	if description_label != null:
		description_label.text = description
		description_label.visible = not description.is_empty()
	if action != null:
		action.text = action_label
		action.theme_type_variation = (
			&"RookframeError" if tone == Tone.DANGER else &"RookframeLabel"
		)
	accessibility_name = title
	accessibility_description = description
