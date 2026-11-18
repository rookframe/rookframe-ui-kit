@tool
extends Button

## Compact navigation or management action with one native button target.
## The caller owns action policy and connects the inherited pressed signal.

enum Tone {
	STANDARD,
	DANGER,
}

var _minimum_height := 0.0
var _minimum_width := 0.0
var _managed_width := 0.0
## The accessible name this row last derived from its title.
var _managed_name := ""

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
	_minimum_height = custom_minimum_size.y
	_managed_width = custom_minimum_size.x
	get_node(^"Content").minimum_size_changed.connect(_fit)
	_refresh()
	_fit()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_THEME_CHANGED, NOTIFICATION_TRANSLATION_CHANGED] and is_node_ready():
		_fit_width()


func _fit() -> void:
	_fit_height()
	_fit_width()


## The copy is laid over the button, so a row whose copy outgrows it grows to
## hold the copy with its insets. Copy that fits keeps the authored height.
func _fit_height() -> void:
	var content: Control = get_node(^"Content")
	var copy := content.get_combined_minimum_size().y
	custom_minimum_size.y = _minimum_height if copy <= _minimum_height else copy + content.offset_top - content.offset_bottom


## The wrapping title reports no width of its own, so a row narrower than its
## copy would run the title into the trailing label. Keep the title's widest
## word, the gap and the trailing label inside the row.
func _fit_width() -> void:
	var content: HBoxContainer = get_node(^"Content")
	var title_label: Label = get_node(^"Content/Copy/Title")
	var font := title_label.get_theme_font("font")
	var font_size := title_label.get_theme_font_size("font_size")
	var widest := 0.0
	for word in tr(title).split(" ", false):
		widest = maxf(widest, ceilf(font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x))
	var action: Control = get_node(^"Content/Action")
	var needed := widest + content.offset_left - content.offset_right
	if action.visible:
		needed += action.get_combined_minimum_size().x + content.get_theme_constant("separation")
	# A width the caller set since the last fit is the new floor.
	if custom_minimum_size.x != _managed_width:
		_minimum_width = custom_minimum_size.x
	_managed_width = maxf(_minimum_width, needed)
	custom_minimum_size.x = _managed_width


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
	# A name the caller set stays; the title names the row only when none is set.
	if accessibility_name.is_empty() or accessibility_name == _managed_name:
		_managed_name = title
		accessibility_name = title
	accessibility_description = description
	if is_node_ready():
		_fit_width()


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
