@tool
extends PanelContainer

## Context-neutral structured row family with stable leading, identity, value,
## status, and action lanes.

signal layout_profile_changed(profile: StringName)

enum Variant {
	DATA,
	DETAIL,
	COMPACT_DETAIL,
	STACKED_DETAIL,
	SUMMARY,
	TABLE,
	HEADER,
	SELECTION_BANNER,
	CATEGORY,
	CATALOGUE,
	PORTRAIT,
	PENDING,
}

const VARIANT_NAMES := [
	"Data",
	"Detail",
	"Compact detail",
	"Stacked detail",
	"Summary",
	"Table",
	"Header",
	"Selection banner",
	"Category",
	"Catalogue",
	"Portrait",
	"Pending",
]

@export var variant := Variant.DATA:
	set(value):
		variant = clampi(value, Variant.DATA, Variant.PENDING)
		_refresh()

@export var title := "Row identity":
	set(value):
		title = value
		_refresh()

@export_multiline var detail := "":
	set(value):
		detail = value
		_refresh()

@export var value_text := "":
	set(value):
		value_text = value
		_refresh()

@export var status_text := "":
	set(value):
		status_text = value
		_refresh()

@export var leading_image: Texture2D:
	set(value):
		leading_image = value
		_refresh()

@export_range(360.0, 960.0, 4.0, "suffix:px") var compact_width := 620.0:
	set(value):
		compact_width = maxf(360.0, value)
		_refresh()

var _profile: StringName = &"wide"


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY or what == NOTIFICATION_RESIZED:
		_refresh()


func get_action_slot() -> Container:
	return get_node(^"Content/ActionSlot") as Container


func _refresh() -> void:
	if not is_inside_tree():
		return
	var content := get_node_or_null(^"Content") as BoxContainer
	var leading := get_node_or_null(^"Content/Leading") as TextureRect
	var title_label := get_node_or_null(^"Content/Copy/Title") as Label
	var detail_label := get_node_or_null(^"Content/Copy/Detail") as Label
	var value_label := get_node_or_null(^"Content/Value") as Label
	var status_label := get_node_or_null(^"Content/Status") as Label
	var compact := variant == Variant.STACKED_DETAIL or (size.x > 0.0 and size.x < compact_width)
	if content != null:
		content.vertical = compact
	if leading != null:
		leading.texture = leading_image
		leading.visible = leading_image != null
		leading.custom_minimum_size = Vector2(80, 80) if variant == Variant.PORTRAIT else Vector2(32, 32)
	if title_label != null:
		title_label.text = title
	if detail_label != null:
		detail_label.text = detail
		detail_label.visible = not detail.is_empty()
	if value_label != null:
		value_label.text = value_text
		value_label.visible = not value_text.is_empty()
	if status_label != null:
		var display_status := "Pending: %s" % status_text if variant == Variant.PENDING and not status_text.is_empty() else status_text
		status_label.text = display_status
		status_label.visible = not display_status.is_empty()
		status_label.theme_type_variation = &"RookframePending" if variant == Variant.PENDING else &"RookframeStatus"
	theme_type_variation = &"RookframeStructuredRowSelected" if variant == Variant.SELECTION_BANNER else &"RookframeStructuredRow"
	accessibility_name = "%s row: %s" % [VARIANT_NAMES[variant], title]
	accessibility_description = detail
	var next_profile: StringName = &"compact" if compact else &"wide"
	if _profile == next_profile:
		return
	_profile = next_profile
	layout_profile_changed.emit(_profile)
