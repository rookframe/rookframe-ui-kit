@tool
extends PanelContainer
## Host-supplied identity art with initials and a native TextureRect fallback.

@export var texture: Texture2D:
	set(value):
		texture = value
		_refresh()

@export var initials := "":
	set(value):
		initials = value
		_refresh()

@export var fallback_texture: Texture2D = preload("res://rookframe/ui/icons/person.svg"):
	set(value):
		fallback_texture = value
		_refresh()

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	var image := get_node_or_null("Image") as TextureRect
	var copy := get_node_or_null("Initials") as Label
	if image == null or copy == null:
		return
	var use_initials := texture == null and not initials.is_empty()
	image.texture = texture if texture != null else fallback_texture
	image.visible = not use_initials
	copy.text = initials
	copy.visible = use_initials
