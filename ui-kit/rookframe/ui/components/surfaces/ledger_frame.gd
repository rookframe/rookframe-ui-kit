@tool
extends Control
## Linked reading leaves behind an existing native layout; no content reparenting.
@export var reduced_motion := false
const REVEAL = preload("res://rookframe/ui/_internal/surfaces/content_reveal.gd")
const STRAP = preload("res://rookframe/ui/assets/action-panel/connector.tres")
var _ink := REVEAL.new()
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
	var previous := Rect2()
	for rect in _sections:
		if not rect.has_area():
			continue
		if previous.has_area():
			var top := previous.end.y - 6
			for x in [maxf(previous.position.x, rect.position.x) + 26, minf(previous.end.x, rect.end.x) - 48]:
				get_node("Bindings").draw_texture_rect(STRAP, Rect2(x, top, 16, maxf(16, rect.position.y - top + 6)), false)
		previous = rect

func _exit_tree() -> void:
	_ink.finish()
