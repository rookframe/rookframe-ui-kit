@tool
extends Control
const Appearance = preload("res://rookframe/ui/_internal/presentation/appearance.gd")
## Linked reading leaves behind an existing native layout; no content reparenting.
@export var reduced_motion := false
const REVEAL = preload("res://rookframe/ui/_internal/surfaces/content_reveal.gd")
var _ink := REVEAL.new()
@export var reveal_shader: Shader:
	set(value):
		_ink.finish()
		reveal_shader = value
		_ink.shader = value
var _sections: Array[Rect2] = []

func _ready() -> void:
	get_node("Bindings").draw.connect(_draw_bindings)

func set_sections(header: Rect2, body: Rect2, footer: Rect2 = Rect2()) -> void:
	_sections = [header, body, footer]
	for index in _sections.size():
		var leaf: Control = get_child(index)
		leaf.visible = _sections[index].has_area()
		leaf.position = _sections[index].position
		leaf.size = _sections[index].size
	get_node("Bindings").queue_redraw()

func reveal(content: Control) -> void:
	_ink.play(content, reduced_motion)

func _draw_bindings() -> void:
	if Appearance.has_hook(self, &"_draw_bindings"):
		Appearance.invoke(self, &"_draw_bindings", [])
		return
	pass

func _exit_tree() -> void:
	_ink.finish()


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
